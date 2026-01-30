# frozen_string_literal: true

# Redmine - project management software
# Copyright (C) 2006-  Jean-Philippe Lang
# This code is released under the GNU General Public License.

module Redmine
  module WikiFormatting
    module Textile
      class EnhancementsScrubber < Loofah::Scrubber
        include Redmine::WikiFormatting::SyntaxHighlight

        def scrub(node)
          case node.name
          when 'code'
            return unless (lang = node['class'].presence)

            text = node.inner_text
            text = text.sub("\n", "") if text.start_with?("\n")
            process(node, text, lang)
          when 'pre'
            apply_copy_pre(node)
          when 'table'
            apply_table_sort(node)
          end
        end

        private

        def apply_copy_pre(node)
          node['data-clipboard-target'] = 'pre'
          node.wrap(pre_wrapper)
          node.parent.prepend_child(copy_button)
        end

        def pre_wrapper
          @pre_wrapper ||= Nokogiri::HTML5.fragment(
            '<div class="pre-wrapper" data-controller="clipboard"></div>'
          ).children.first
        end

        def copy_button
          icon = ApplicationController.helpers.sprite_icon('copy-pre-content', size: 18)
          button_copy = ApplicationController.helpers.l(:button_copy)
          html = '<a class="copy-pre-content-link icon-only" title="' + button_copy + '" data-action="clipboard#copyPre">' + icon + '</a>'
          @copy_button ||= Nokogiri::HTML5.fragment(html).children.first
        end

        def apply_table_sort(node)
          return unless Setting.wiki_tablesort_enabled?

          rows = node.search('tr')
          return if rows.size < 3

          tr = rows.first
          return if tr.search('th').blank?

          node['data-controller'] = 'tablesort'
          tr['data-sort-method'] = 'none'
          tr.search('td').each do |td|
            td['data-sort-method'] = 'none'
          end
        end
      end
    end
  end
end
