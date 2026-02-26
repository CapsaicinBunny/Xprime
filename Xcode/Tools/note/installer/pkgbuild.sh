#!/bin/bash

# Your AppleID, TeamID, Password and Name (An app-specific password NOT! AppleID password)
if [ -z "$APPLE_ID" ]; then
    source ./notarization.sh
fi

cd ../
project_dir=$(find . -maxdepth 1 -type d -name "*.xcodeproj" | head -n 1)
cd installer
project_file=$(basename "$project_dir")
PROJECT_NAME="${project_file%.xcodeproj}"


pkgbuild --identifier uk.insoft.$PROJECT_NAME \
         --root package-root \
         --version 1.0 --install-location / \
         $PROJECT_NAME.pkg
         
productsign --sign "Developer ID Installer: $YOUR_NAME ($TEAM_ID)" $PROJECT_NAME.pkg $PROJECT_NAME-signed.pkg

xcrun notarytool submit --apple-id $APPLE_ID \
                        --password $PASSWORD \
                        --team-id $TEAM_ID \
                        --wait $NAME-signed.pkg
                        
# Staple
xcrun stapler staple $PROJECT_NAME-signed.pkg

# Verify
xcrun stapler validate $PROJECT_NAME-signed.pkg

# Gatekeeper
spctl --assess --type install --verbose $PROJECT_NAME-signed.pkg

rm $PROJECT_NAME.pkg
mv $PROJECT_NAME-signed.pkg ../$PROJECT_NAME-universal.pkg
