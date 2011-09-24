module Merge
  module SuperTags
    # Merge tags and customfields
    # - ignored_attr contains values such as {"TagOne" => ["field_one"]}

    def merge_super_tags(dup, master, ignored_attr = {})
      shared_tags = dup.tags & master.tags
      uniq_dup_tags = dup.tags - master.tags
      all_tags = (dup.tags + master.tags).uniq

      # Add the duplicate's unique tags to the master
      uniq_dup_tags.each do |tag|
        dup.taggings.find_by_tag_id(tag.id).update_attribute(:taggable_id, master.id)

        # If tag has customfields, set the customizable_id to the master object
        if tag.customfields.any?
          dup.send("tag#{tag.id}").update_attribute(:customizable_id, master.id)
        end
      end

      # Merge custom fields on shared tags, if dup has any specified
      shared_tags.select{|t| t.customfields.any? }.each do |tag|
        if customfields = dup.send("tag#{tag.id}")
          # Prepare a hash of customfield values as the merge attributes
          custom_fields = tag.customfields.map{|c| c.field_name }
          merge_attributes = customfields.attributes.select do |k, v|
            custom_fields.include?(k)
          end
          # Remove ignored attributes as directed
          (ignored_attr[tag.name.to_s.strip] || []).each {|k| merge_attributes.delete(k) }

          # Update the master's custom field values with the dup's filtered values
          if master_customfields = master.send("tag#{tag.id}")
            master_customfields.update_attributes(merge_attributes)
          else
            master.update_attribute("tag#{tag.id}_attributes".to_sym, merge_attributes)
          end
        end
      end

      master.tag_list = all_tags.map(&:name).join(", ")
      master
    end
  end
end

