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

// There is no CSS selector for finding comment nodes.
function getComments(context) {
  var foundComments = []
  var stack = [context]

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

document.addEventListener('DOMContentLoaded', function() {
  console.log(findSpecimens().map(x => x.getBox()))
})
