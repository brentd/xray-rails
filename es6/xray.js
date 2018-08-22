const findSpecimens = () => {
  const startComments = getComments(document.body)
    .filter(node => node.textContent.indexOf('XRAY START') !== -1)

  return startComments.reduce((specimens, comment) => {
    const [_, id, path] = comment.data.match(/^XRAY START (\d+) (.*)$/)
    const contents = []
    let el = comment.nextSibling

    while (el.nodeType !== 8 && el.textContent !== 'XRAY END ' + id) {
      if (el.nodeType === 1 && el.tagName !== 'script')
        contents.push(el)
      el = el.nextSibling
    }

    if (contents.length > 0) {
      specimens.push(new Specimen(path, contents))
    }

    return specimens
  }, [])
}

class Specimen {
  constructor(path, contents) {
    this.path = path
    this.contents = contents

    const box = this.getBox()

    this.el = document.createElement('div')
    this.el.style.position = 'absolute'
    this.el.style.background = 'rgba(255,255,255,0.5)'
    this.el.style.top = box.top + 'px'
    this.el.style.left = box.left + 'px'
    this.el.style.width = box.width + 'px'
    this.el.style.height = box.height + 'px'
  }

  getBox() {
    if (this.contents.length === 0) {
      return { width: 0, height: 0, top: 0, left: 0 }
    }

    const widths  = this.contents.map(node => node.offsetWidth || 0)
    const heights = this.contents.map(node => node.offsetHeight || 0)
    const lefts   = this.contents.map(node => node.offsetLeft || 0)
    const tops    = this.contents.map(node => node.offsetTop || 0)

    return {
      width:  Math.max(...widths),
      height: Math.max(...heights),
      left:   Math.min(...lefts),
      top:    Math.min(...tops)
    }
  }
}

// There is no CSS selector for comment nodes, so this function walks the DOM.
function getComments(rootNode) {
  var foundComments = []

  // A stack should be faster than recursion.
  var stack = [rootNode]

  while (stack.length > 0) {
    var el = stack.pop()
    for (var i = 0; i < el.childNodes.length; i++) {
      var node = el.childNodes[i]
      if (node.nodeType === Node.COMMENT_NODE) {
        foundComments.push(node)
      } else {
        stack.push(node)
      }
    }
  }

  return foundComments
}

class Overlay {
  constructor() {
    this.showing = false
    this.specimens = []
    this.escHandler = e => e.keyCode === 27 && this.hide()

    this.el = document.createElement('div')
    this.el.style.position   = 'fixed'
    this.el.style.top        = 0
    this.el.style.right      = 0
    this.el.style.bottom     = 0
    this.el.style.left       = 0
    this.el.style.background = 'rgba(0,0,0,0.6)'
  }

  toggle() {
    this.showing ? this.hide() : this.show()
  }

  show() {
    document.addEventListener('keydown', this.escHandler)
    this.showing = true

    this.specimens.forEach(specimen => {
      this.el.appendChild(specimen.el)
    })

    document.body.appendChild(this.el)
  }

  hide() {
    document.removeEventListener('keydown', this.escHandler)
    this.showing = false
    document.body.removeChild(this.el)
  }
}

const isMac = navigator.platform.toLowerCase().indexOf('mac') !== -1
const overlay = new Overlay()

document.addEventListener('DOMContentLoaded', function() {
  document.addEventListener('keydown', e => {
    if ((isMac ? e.metaKey : e.ctrlKey) && e.shiftKey && e.keyCode === 88) {
      overlay.specimens = findSpecimens()
      overlay.toggle()
    }
  })
})
