# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

require 'date'
require 'hpricot'

def pretty_date(date)
  return "bad date" unless date
  date.strftime("%A, %e %B %Y")
end

# Needed so we get a trailing /
def link_for_tag(tag, base_url)
  %[<a href="#{h base_url}#{h tag}/" rel="tag">#{h tag}</a>]
end

def home
  @home ||= @items.find(&:home?)
end


def nav_items
  @nav_items ||= [home] + @config[:nav_items].map do |identifier|
    home.children.find {|i| i.identifier == identifier }
  end
end

def sorted_news
  @sorted_news ||= (articles + sorted_releases).sort_by {|i| i.created_at }.reverse
end

def sorted_releases
  @sorted_releases ||= @items.select {|i| i.identifier =~ %r[^/\w+/\w+/releases/v] }.sort_by {|i| i.created_at }.reverse
end

def breadcrumbs_for_path(path)
  @breadcrumbs_path_cache ||= {}
  @breadcrumbs_path_cache[path] ||= begin
    head = (path == '/' ? [] :  breadcrumbs_for_path(path.sub(/[^\/]+\/$/, '')) )
    tail = [ item_with_path(path) ]

    head + tail
  end
end

def item_with_path(path)
  @path_cache ||= {}
  @path_cache[path] ||= begin
    @items.find { |i| i.path == path }
  end
end

def breadcrumbs_trail
  breadcrumbs_for_path(@item.path)
end

class Nanoc3::Item
  def summary
    # Just include the first paragraph (article) or list (release).
    (Hpricot(compiled_content).at("p|ul") || "(empty article)").to_s
  end

  def feed_summary
    excerptize strip_html(compiled_content), length: 140
  end

  def home?; identifier == '/'; end

  def hidden?; self[:is_hidden]; end

  def year; self[:created_at].year; end
  def month; self[:created_at].month; end
  def month_name; Date.new(2000, month, 1).strftime("%B"); end
  def day; self[:created_at].day; end

  def created_at; self[:created_at] || raise(path); end
  def modified_at; self[:modified_at] || created_at; end

  def permalink; "http://spooner.github.com#{path}"; end
  def title; self[:title]; end
  def kind; self[:kind]; end

  def article?; kind == 'article'; end
  def project?; kind == 'project'; end

  def name; File.basename(identifier); end
end