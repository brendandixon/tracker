module ApplicationHelper

  def awesome_button_to(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second
      glyph_button_to(capture(&block), options, html_options)
    else
      name         = args[0]
      options      = args[1] || {}
      html_options = args[2] || {}

      font_button_to(:awesome, name, options, html_options)
    end
  end

  def awesome_link_to(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second
      glyph_link_to(capture(&block), options, html_options)
    else
      name         = args[0]
      options      = args[1] || {}
      html_options = args[2] || {}

      font_link_to(:awesome, name, options, html_options)
    end
  end

  def glyph_button_to(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second
      glyph_button_to(capture(&block), options, html_options)
    else
      name         = args[0]
      options      = args[1] || {}
      html_options = args[2] || {}

      font_button_to(:glyphicon, name, options, html_options)
    end
  end

  def glyph_link_to(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second
      glyph_link_to(capture(&block), options, html_options)
    else
      name         = args[0]
      options      = args[1] || {}
      html_options = args[2] || {}

      font_link_to(:glyphicon, name, options, html_options)
    end
  end

  def flat_select_tag(name, option_tags = nil, options = {})
    "<div class='flat-select'><i class='awesome awesome-caret-down'></i>#{select_tag(name, option_tags, options)}</div>".html_safe
  end

  def status_to_classes(state)
    case state
    when 'completed' then ' awesome awesome-circle completed'
    when 'in_progress' then ' awesome awesome-adjust in_progress'
    when 'pending' then ' awesome awesome-circle-blank pending'
    else ' awesome awesome-ban-circle'
    end
  end

  def status_tag(content, state)
    content_tag :span, class: "status #{state}" do
      "<i class='#{status_to_classes(state)}'></i>#{content}".html_safe
    end
  end

  private

  def font_button_to(family, name, options, html_options)
    html_options, options, name = options, name, nil if name.is_a?(Hash)

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
    
    glyph_classes = "#{family} #{html_options.delete('glyph')}"
    wrapper_classes = "#{family} glyphbutton #{'disabled' if html_options.has_key?('disabled')}"

    form_options.merge!(method: form_method, action: url)
    form_options.merge!("data-remote" => "true") if remote

        
    "#{tag(:form, form_options, true)}<div class='#{wrapper_classes}'><i class='#{glyph_classes}'></i>#{method_tag}#{tag("input", html_options)}#{request_token_tag}</div></form>".html_safe
  end

  def font_link_to(family, name, options, html_options)
    html_options, options, name = options, name, nil if name.is_a?(Hash)

    name = "<span>#{ERB::Util.html_escape(name)}</span>" if name.present?
    
    html_options = html_options.stringify_keys
    is_disabled = html_options.delete('disabled')

    html_options = html_options.merge('class' => "#{family} glyphlink" << (is_disabled ? ' disabled' : ''))
    glyph = html_options.delete('glyph')

    html_options = convert_options_to_data_attributes(options, html_options)
    url = url_for(options)

    href = html_options['href']
    tag_options = tag_options(html_options)

    if is_disabled
      "<span #{tag_options}><i class='#{family} #{glyph}'></i></span>".html_safe
    else
      href_attr = "href=\"#{ERB::Util.html_escape(url)}\"" unless href
      "<a #{href_attr}#{tag_options}><i class='#{family} #{glyph}'></i>#{name}</a>".html_safe
    end
  end

end
