
j2re_control() {
    build_depends="libasound2, libgl1-mesa-glx, libgtk2.0-0, libxslt1.1, libxtst6, libxxf86vm1"
    j2se_control
    if [ "$create_cert_softlinks" == "true" ]; then
        depends="ca-certificates-java"
    fi
    for i in `seq 5 ${j2se_release}`;
    do
        provides_runtime="${provides_runtime} java${i}-runtime,"
        provides_headless="${provides_headless} java${i}-runtime-headless,"
    done
    cat << EOF
Package: $j2se_package
Architecture: any
Depends: \${misc:Depends}, $depends
Recommends: netbase, \${shlibs:Depends}
Provides: java-virtual-machine, java-runtime, java2-runtime, $provides_runtime java-runtime-headless, java2-runtime-headless, $provides_headless java-browser-plugin
Description: $j2se_title
 The Java(TM) SE Runtime Environment contains the Java virtual machine,
 runtime class libraries, and Java application launcher that are
 necessary to run programs written in the Java programming language.
 It is not a development environment and does not contain development
 tools such as compilers or debuggers.  For development tools, see the
 Java SE Development Kit (JDK).
 .
 This package has been automatically created with java-package ($version).
EOF
}

function install_security_policy_jre() {
    local jce_zip="$1"
    local dest="$2/lib/security"
    echo "Updating to unlimited jurisdiction security policy using $jce_zip"
    for f in {US_export,local}_policy.jar; do
        unzip -p "$jce_zip" "jce/$f" > "$dest/$f"
    done
}

# build debian package
j2re_run() {
    echo
    diskfree "$j2se_required_space"
    read_maintainer_info
    j2se_package="$j2se_vendor-java${j2se_release}u$j2se_update-jre"
    j2se_name="jre-${j2se_release}u$j2se_update-$j2se_vendor-$j2se_arch"
    local target="$package_dir/$j2se_name"
    install -d -m 755 "$( dirname "$target" )"
    extract_bin "$archive_path" "$j2se_expected_min_size" "$target"
    if [[ -n "$jce_policy_zipfile" ]]; then
        install_security_policy_jre "$jce_policy_zipfile" "$target"
    fi
    rm -rf "$target/.systemPrefs"
    echo "9" > "$debian_dir/compat"
    j2se_readme > "$debian_dir/README.Debian"
    j2se_changelog > "$debian_dir/changelog"
    j2re_control > "$debian_dir/control"
    j2se_copyright > "$debian_dir/copyright"
    j2se_rules > "$debian_dir/rules"
    chmod +x "$debian_dir/rules"
    j2se_install_scripts
    install -d "$target/debian"
    j2se_info > "$target/debian/info"
    eval "$j2se_jinfo" > "$package_dir/.$j2se_name.jinfo"
    echo ".$j2se_name.jinfo $jvm_base" > "$debian_dir/install"
    echo "$j2se_name $jvm_base" >> "$debian_dir/install"
    j2se_build
}
