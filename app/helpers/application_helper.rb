module ApplicationHelper

  def glyph_button_to(name, options = {}, html_options = {})
    html_options = html_options.stringify_keys
    convert_boolean_attributes!(html_options, %w( disabled ))

    method_tag = ''
    if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
      method_tag = tag('input', type: 'hidden', name: '_method', value: method.to_s)
    end

    form_method = method.to_s == 'get' ? 'get' : 'post'
    form_options = html_options.delete('form') || {}
    form_options[:class] ||= html_options.delete('form_class') || 'button_to'
        
    remote = html_options.delete('remote')
        
    request_token_tag = ''
    if form_method == 'post' && protect_against_forgery?
      request_token_tag = tag(:input, type: "hidden", name: request_forgery_protection_token.to_s, value: form_authenticity_token)
    end

    url = options.is_a?(String) ? options : self.url_for(options)
    name ||= url

    html_options = convert_options_to_data_attributes(options, html_options)

    html_options.merge!("type" => "submit", "value" => name)
    
    wrapper_classes = "glyphicons iconic #{html_options.delete('glyph')} #{'disabled' if html_options.has_key?('disabled')}"

    form_options.merge!(method: form_method, action: url)
    form_options.merge!("data-remote" => "true") if remote
        
    "#{tag(:form, form_options, true)}<div class='#{wrapper_classes}'><i></i>#{method_tag}#{tag("input", html_options)}#{request_token_tag}</div></form>".html_safe
  end

  def glyph_link_to(*args)
    name         = '&nbsp;'.html_safe
    options      = args[0] || {}
    html_options = args[1] || {}

    html_options = html_options.stringify_keys
    html_options['class'] ||= ''
    html_options['class'] << " glyphicons iconic #{html_options.delete('glyph')}"

    html_options = convert_options_to_data_attributes(options, html_options)
    url = url_for(options)

    href = html_options['href']
    tag_options = tag_options(html_options)

    href_attr = "href=\"#{ERB::Util.html_escape(url)}\"" unless href
    "<a #{href_attr}#{tag_options}><i></i>#{ERB::Util.html_escape(name || url)}</a>".html_safe
  end
end
