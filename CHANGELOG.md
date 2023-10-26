v2.0.0 - 2023-10-17

* Compatible only with fat_free_crm v0.21 and above
* Major work to provide compatibility with Rails 6.1. Not backwards compatible.

v.1.3.1

Compatible with ffcrm v0.13.x

* Refactored merge overrides into separate merge_controller
* Moved to jQuery and Coffeescript
* Overhauled spec tests - using dummy engine application rather than depending on fat_free_crm
* Abstracted out merge logic so it is easy to write merge code for other entities. Currently we only provide support for contacts and accounts **patches welcome**
* Added merge_hook so you can add your own customisations (see below)
* Fixed bug where account duplicate tags were always ignored
* Fixed bug where assigned_to, user_id and reports_to were not always set correctly
* Added ability to merge addresses visually
* Moved styles out of template and into css
* Custom field labels are translated on merge form (I18n.t('active_record.attributes.contact.cf_your_custom_field_name')
* Improved subscribed_users formatting
* Fixed javascript bug where not all merge links were yielding popups. (Have to listen for both jQuery and prototype events.)
* Fixed final redirect to merged entity when using direct url to merge
* Corrected module namespacing
* Made aliases more production ready. Added api_key authentication (see docs)
