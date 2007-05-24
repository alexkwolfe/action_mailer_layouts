module ActionMailer
  class Base

    # Specify the layout name
    adv_attr_accessor :layout

    def render_message(method_name, body)
      layout = @layout ? @layout.to_s : self.class.to_s.underscore
      md = /^([^\.]+)\.([^\.]+\.[^\.]+)\.(rhtml|rxml)$/.match(method_name)
      layout << ".#{md.captures[1]}" if md && md.captures[1]
      layout << ".rhtml"
      if File.exists?(File.join(layouts_path, layout))
        body[:content_for_layout] = render(:file => method_name, :body => body)
        ActionView::Base.new(layouts_path, body, self).render(:file => layout)
      else
        render :file => method_name, :body => body
      end
    end
  
    def layouts_path
      File.join(template_root, 'layouts')
    end 
    
    private
      # Extend the template class instance with our controller's helper module.
      def initialize_template_class_with_helper(path,assigns)
        returning(layout = initialize_template_class_without_helper(path,assigns)) do
          layout.extend self.class.master_helper_module
        end
      end
      alias_method_chain :initialize_template_class, :helper   
  end
end