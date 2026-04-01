#!/usr/bin/env python3
"""
Script to automatically add Widget Extension to Xcode project
This modifies the project.pbxproj file to include the TwinAmWidget target
"""

import os
import sys
import uuid
import re

def generate_uuid():
    """Generate a unique 24-character hex string like Xcode does"""
    return uuid.uuid4().hex[:24].upper()

def add_widget_extension(project_path):
    """Add Widget Extension target to Xcode project"""
    
    pbxproj_path = os.path.join(project_path, 'Runner.xcodeproj', 'project.pbxproj')
    
    if not os.path.exists(pbxproj_path):
        print(f"❌ Error: project.pbxproj not found at {pbxproj_path}")
        return False
    
    print(f"📝 Reading {pbxproj_path}")
    
    with open(pbxproj_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if widget already exists
    if 'TwinAmWidget' in content:
        print("✅ Widget Extension already exists in project")
        return True
    
    print("🔧 Adding Widget Extension to project...")
    
    # Generate UUIDs for various objects
    widget_target_uuid = generate_uuid()
    widget_build_config_list_uuid = generate_uuid()
    widget_debug_config_uuid = generate_uuid()
    widget_release_config_uuid = generate_uuid()
    widget_sources_phase_uuid = generate_uuid()
    widget_frameworks_phase_uuid = generate_uuid()
    widget_resources_phase_uuid = generate_uuid()
    widget_swift_file_uuid = generate_uuid()
    widget_swift_file_ref_uuid = generate_uuid()
    widget_info_plist_uuid = generate_uuid()
    widget_entitlements_uuid = generate_uuid()
    widget_group_uuid = generate_uuid()
    widget_product_ref_uuid = generate_uuid()
    widget_container_proxy_uuid = generate_uuid()
    widget_target_dependency_uuid = generate_uuid()
    
    # 1. Add PBXBuildFile section entries
    build_files_section = f"""/* Begin PBXBuildFile section */
		{widget_swift_file_uuid} /* TwinAmWidget.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {widget_swift_file_ref_uuid} /* TwinAmWidget.swift */; }};"""
    
    content = content.replace('/* Begin PBXBuildFile section */', build_files_section)
    
    # 2. Add PBXContainerItemProxy
    container_proxy = f"""/* Begin PBXContainerItemProxy section */
		{widget_container_proxy_uuid} /* PBXContainerItemProxy */ = {{
			isa = PBXContainerItemProxy;
			containerPortal = 97C146E61CF9000F007C117D /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = {widget_target_uuid};
			remoteInfo = TwinAmWidget;
		}};"""
    
    if '/* Begin PBXContainerItemProxy section */' in content:
        content = content.replace('/* Begin PBXContainerItemProxy section */', container_proxy)
    else:
        # Add before PBXCopyFilesBuildPhase
        content = content.replace('/* Begin PBXCopyFilesBuildPhase section */', 
                                  container_proxy + '\n/* End PBXContainerItemProxy section */\n\n/* Begin PBXCopyFilesBuildPhase section */')
    
    # 3. Add PBXFileReference for widget files
    file_ref_pattern = r'(/\* Begin PBXFileReference section \*/)'
    file_refs = f"""/* Begin PBXFileReference section */
		{widget_product_ref_uuid} /* TwinAmWidget.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = TwinAmWidget.appex; sourceTree = BUILT_PRODUCTS_DIR; }};
		{widget_swift_file_ref_uuid} /* TwinAmWidget.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TwinAmWidget.swift; sourceTree = "<group>"; }};
		{widget_info_plist_uuid} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};
		{widget_entitlements_uuid} /* TwinAmWidget.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = TwinAmWidget.entitlements; sourceTree = "<group>"; }};"""
    
    content = re.sub(file_ref_pattern, file_refs, content)
    
    # 4. Add PBXFrameworksBuildPhase for widget
    frameworks_phase = f"""		{widget_frameworks_phase_uuid} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
    
    # Insert before /* End PBXFrameworksBuildPhase section */
    content = content.replace('/* End PBXFrameworksBuildPhase section */', 
                              frameworks_phase + '\n/* End PBXFrameworksBuildPhase section */')
    
    # 5. Add PBXGroup for widget
    widget_group = f"""		{widget_group_uuid} /* TwinAmWidget */ = {{
			isa = PBXGroup;
			children = (
				{widget_swift_file_ref_uuid} /* TwinAmWidget.swift */,
				{widget_info_plist_uuid} /* Info.plist */,
				{widget_entitlements_uuid} /* TwinAmWidget.entitlements */,
			);
			path = TwinAmWidget;
			sourceTree = "<group>";
		}};"""
    
    # Add to main group - find the Runner group and add widget as sibling
    runner_group_pattern = r'(97C146F01CF9000F007C117D /\* Runner \*/ = \{[^}]+\};)'
    content = re.sub(runner_group_pattern, r'\1\n' + widget_group, content)
    
    # 6. Add widget group to main project children
    # Find the main group children array and add widget group reference
    main_children_pattern = r'(children = \([^)]*97C146F01CF9000F007C117D /\* Runner \*/,)'
    content = re.sub(main_children_pattern, r'\1\n				' + widget_group_uuid + ' /* TwinAmWidget */,', content)
    
    # 7. Add product reference to Products group
    products_pattern = r'(name = Products;\s+children = \([^)]*)'
    content = re.sub(products_pattern, r'\1\n				' + widget_product_ref_uuid + ' /* TwinAmWidget.appex */,', content)
    
    # 8. Add PBXNativeTarget for widget
    widget_target = f"""		{widget_target_uuid} /* TwinAmWidget */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {widget_build_config_list_uuid} /* Build configuration list for PBXNativeTarget "TwinAmWidget" */;
			buildPhases = (
				{widget_sources_phase_uuid} /* Sources */,
				{widget_frameworks_phase_uuid} /* Frameworks */,
				{widget_resources_phase_uuid} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = TwinAmWidget;
			productName = TwinAmWidget;
			productReference = {widget_product_ref_uuid} /* TwinAmWidget.appex */;
			productType = "com.apple.product-type.app-extension";
		}};"""
    
    # Insert before /* End PBXNativeTarget section */
    content = content.replace('/* End PBXNativeTarget section */', 
                              widget_target + '\n/* End PBXNativeTarget section */')
    
    # 9. Add PBXResourcesBuildPhase
    resources_phase = f"""		{widget_resources_phase_uuid} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
    
    content = content.replace('/* End PBXResourcesBuildPhase section */', 
                              resources_phase + '\n/* End PBXResourcesBuildPhase section */')
    
    # 10. Add PBXSourcesBuildPhase
    sources_phase = f"""		{widget_sources_phase_uuid} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{widget_swift_file_uuid} /* TwinAmWidget.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
    
    content = content.replace('/* End PBXSourcesBuildPhase section */', 
                              sources_phase + '\n/* End PBXSourcesBuildPhase section */')
    
    # 11. Add PBXTargetDependency
    target_dependency = f"""		{widget_target_dependency_uuid} /* PBXTargetDependency */ = {{
			isa = PBXTargetDependency;
			target = {widget_target_uuid} /* TwinAmWidget */;
			targetProxy = {widget_container_proxy_uuid} /* PBXContainerItemProxy */;
		}};"""
    
    if '/* Begin PBXTargetDependency section */' in content:
        content = content.replace('/* End PBXTargetDependency section */', 
                                  target_dependency + '\n/* End PBXTargetDependency section */')
    else:
        # Create the section
        content = content.replace('/* Begin PBXVariantGroup section */', 
                                  '/* Begin PBXTargetDependency section */\n' + target_dependency + 
                                  '\n/* End PBXTargetDependency section */\n\n/* Begin PBXVariantGroup section */')
    
    # 12. Add widget target to Runner dependencies
    runner_dependencies_pattern = r'(97C146ED1CF9000F007C117D /\* Runner \*/ = \{[^}]*dependencies = \()'
    content = re.sub(runner_dependencies_pattern, 
                     r'\1\n				' + widget_target_dependency_uuid + ' /* PBXTargetDependency */,', content)
    
    # 13. Add XCBuildConfiguration for widget (Debug and Release)
    widget_debug_config = f"""		{widget_debug_config_uuid} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME = WidgetBackground;
				CODE_SIGN_ENTITLEMENTS = TwinAmWidget/TwinAmWidget.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = TwinAmWidget/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = TwinAmWidget;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				IPHONEOS_DEPLOYMENT_TARGET = 14.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
					"@executable_path/../../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.twinam.app.TwinAmWidget;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};"""
    
    widget_release_config = f"""		{widget_release_config_uuid} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME = WidgetBackground;
				CODE_SIGN_ENTITLEMENTS = TwinAmWidget/TwinAmWidget.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = TwinAmWidget/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = TwinAmWidget;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				IPHONEOS_DEPLOYMENT_TARGET = 14.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
					"@executable_path/../../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.twinam.app.TwinAmWidget;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};"""
    
    content = content.replace('/* End XCBuildConfiguration section */', 
                              widget_debug_config + '\n' + widget_release_config + '\n/* End XCBuildConfiguration section */')
    
    # 14. Add XCConfigurationList for widget
    widget_config_list = f"""		{widget_build_config_list_uuid} /* Build configuration list for PBXNativeTarget "TwinAmWidget" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{widget_debug_config_uuid} /* Debug */,
				{widget_release_config_uuid} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};"""
    
    content = content.replace('/* End XCConfigurationList section */', 
                              widget_config_list + '\n/* End XCConfigurationList section */')
    
    # 15. Add widget target to project targets
    project_targets_pattern = r'(targets = \([^)]*97C146ED1CF9000F007C117D /\* Runner \*/,)'
    content = re.sub(project_targets_pattern, r'\1\n				' + widget_target_uuid + ' /* TwinAmWidget */,', content)
    
    # Write back to file
    print(f"💾 Writing modified project file...")
    with open(pbxproj_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Widget Extension successfully added to Xcode project!")
    return True

if __name__ == '__main__':
    ios_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'ios')
    
    if not os.path.exists(ios_dir):
        print(f"❌ Error: iOS directory not found at {ios_dir}")
        sys.exit(1)
    
    success = add_widget_extension(ios_dir)
    sys.exit(0 if success else 1)
