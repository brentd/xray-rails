require_relative '../lib/xray-rails'

class String
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "").chomp!
  end
end