module Carrierwave
  module Base64
    module Adapter
      def mount_base64_uploader(attribute, uploader_class, options = {})
        mount_uploader attribute, uploader_class, options
        mount_uploader_file_name options[:file_name]

        define_method "#{attribute}=" do |data|
          send "#{attribute}_will_change!" if data.present?

          if data.present? && data.is_a?(String) && data.strip.start_with?("data")
            super Carrierwave::Base64::Base64StringIO.new(
              data.strip, file_name: try(file_name_attribute)
            )
          else
            super(data)
          end
        end
      end

      private

      def mount_uploader_file_name(attribute)
        return if attribute.blank?
        attribute == true && attribute = :file_name
        attr_accessor attribute

        define_method 'file_name_attribute' do
          attribute
        end

        define_method 'attributes=' do |new_attributes|
          # Ensure file_name is assigned before actual file
          super new_attributes.slice(file_name_attribute.to_sym)
          super new_attributes
        end

        define_method 'assign_attributes' do |new_attributes|
          # Ensure file_name is assigned before actual file
          super new_attributes.slice(file_name_attribute.to_sym)
          super new_attributes
        end
      end
    end
  end
end
