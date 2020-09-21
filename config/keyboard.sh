# Build an xpath expression to get a keyboard identifier from an ioreg plist.
vendor_id_xpath="//key[contains(text(), 'VendorID')]/following-sibling::integer/text()"
product_id_xpath="//key[contains(text(), 'ProductID')]/following-sibling::integer/text()"
xpath="concat($vendor_id_xpath, '-', $product_id_xpath, '-0')"

# New setting: remap "Caps Lock" (30064771129) to "Control" (30064771300).
remap='<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771300</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer></dict>'

# Write the setting.
keyboard_id=$(ioreg -c AppleEmbeddedKeyboard -r -a | xmllint --xpath "$xpath" -)
defaults -currentHost write -g com.apple.keyboard.modifiermapping.$keyboard_id "$remap"
