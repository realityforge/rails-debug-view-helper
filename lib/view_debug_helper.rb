# Add something like the following to get debug output in separate popup
#  <botton onclick="show_debug_popup(); return false;">Show debug popup</button>
#  <%= debug_popup %>
module ViewDebugHelper
  
  def debug_popup
    popup_create do |script| 
      script << add("<html><head><title>Rails Debug Console_#{@controller.class.name}</title></head><body>")
      script << add("<style type='text/css'> body {background-color:#FFFFFF;} table {width:100%;border: 0;} th {background-color:#CCCCCC;font-weight: bold;} td {background-color:#EEEEEE; vertical-align: top;} td.key {color: blue;} td {color: green;}</style><table><colgroup id='key-column'/>" )
      popup_header(script,'Rails Debug Console')

      if ! @controller.params.nil?
        popup_header(script,'Request Parameters:')
        @controller.params.each do |key, value| 
          popup_data(script,h(key),h(value.inspect).gsub(/,/, ',<br/>')) unless IGNORE.include?(key)
        end
      end

      dump_vars(script,'Session Variables:',@controller.instance_variable_get("@data"))
      dump_vars(script,'Flash Variables:',@controller.instance_variable_get("@flash"))
      dump_vars(script,'Assigned Template Variables:',@controller.assigns)
      script << add('</table></body></html>')
      
    end
  end

  private

  IGNORE = ['template_root', 'template_class', 'response', 'template', 'session', 'url', 'params', 'subcategories', 'ignore_missing_templates', 'cookies', 'request', 'logger', 'flash', 'headers' ] unless const_defined?(:IGNORE)

  def dump_vars(script,header,vars)
      return if vars.nil?
      popup_header(script,header)
      vars.each {|k,v| popup_data(script,h(k),dump_obj(v)) unless IGNORE.include?(k)}
  end

  def popup_header(script,heading); script << add( "<tr><th colspan='2'>#{heading}</th></tr>" ); end

  def popup_data(script,key,value); script << add( "<tr><td class='key'>#{key}</td><td>#{value}</td></tr>" ); end
  
  def popup_create
    script = "<script language='javascript'>\n<!--\n"
    script << "function show_debug_popup() {\n"
    script << "_rails_console = window.open(\"\",\"#{@controller.class.name}\",\"width=680,height=600,resizable,scrollbars=yes\");\n"
    yield script
    script << "_rails_console.document.close();\n"
    script << "}\n"
    script << "-->\n</script>"
  end
  
  def add(msg)
    "_rails_console.document.write(\"#{msg}\")\n"
  end  

  def dump_obj(object)
    begin
      Marshal::dump(object)
      "<pre>#{h(object.to_yaml).gsub("  ", "&nbsp; ").gsub("\n", "<br/>\"+\n\"" )}</pre>"
    rescue Object => e
      # Object couldn't be dumped, perhaps because of singleton methods -- this is the fallback
      "<pre>#{h(object.inspect)}</pre>"
    end
  end
end

ActionController::Base.class_eval do
  helper :view_debug
end
