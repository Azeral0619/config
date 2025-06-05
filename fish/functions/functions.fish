function MMCV -a cuda_version torch_version -d "Return MMCV download url that fits cuda_version and torch_version"
    if test (count $argv) -ne 2
        echo "Usage: MMCV <cuda_version> <torch_version>"
        echo "Example: MMCV cuda11.8 torch2.1"
        return 1
    end

    set cuda_version (string replace -a 'cuda' 'cu' (string replace -a '.' '' $cuda_version))

    set url "https://download.openmmlab.com/mmcv/dist/$cuda_version/$torch_version/index.html"

    if curl --output /dev/null --silent --head --fail $url
        echo $url
    else
        echo "Error: URL is invalid or not reachable: $url"
        return 1
    end
end

function proxy_on -a port ip -d "Enable http/https proxy"
    if test (count $argv) -gt 2
        echo "Usage: proxy_on <port> <ip>"
        echo "Example: proxy_on 7890 127.0.0.1"
    end
    if test -z $port
        set port 7890
    end
    if test -z $ip
        set ip localhost
    end
    set -gx http_proxy "http://$ip:$port"
    set -gx https_proxy "http://$ip:$port"
end

function proxy_off -d "Disable http/https proxy"
    set -e http_proxy
    set -e https_proxy
end

function extract -d "All in one decompress"
    if test (count $argv) -eq 0
        echo "Usage: extract <file1> <file2> ..."
        echo "Supported formats: .zip, .rar, .bz2, .gz, .tar, .tbz2, .tgz, .Z, .7z, .xz, .exe, .tar.bz2, .tar.gz, .tar.xz, .zlib, .cso, .zst, .lzma, .cbr, .cbz, .epub, .apk, .arj, .cab, .cb7, .chm, .deb, .iso, .lzh, .msi, .pkg, .rpm, .udf, .wim, .xar, .vhd, .cpio, .cba, .ace, .zpaq, .arc, .dmg"
        return 1
    end

    set success_files
    set failed_files

    for file in $argv
        if not test -f $file
            echo "Error: File '$file' does not exist."
            set failed_files $failed_files $file
            continue
        end

        switch $file
            case '*.cbt' '*.tar.gz' '*.tgz' '*.tar.bz2' '*.tbz2' '*.tar.xz' '*.txz' '*.tar'
                tar --auto-compress -xvf $file
            case '*.lzma'
                unlzma $file
            case '*.bz2'
                bunzip2 $file
            case '*.cbr' '*.rar'
                unrar x -ad $file
            case '*.gz'
                gunzip $file
            case '*.cbz' '*.epub' '*.zip'
                unzip $file
            case '*.z'
                uncompress $file
            case '*.7z' '*.apk' '*.arj' '*.cab' '*.cb7' '*.chm' '*.deb' '*.iso' '*.lzh' '*.msi' '*.pkg' '*.rpm' '*.udf' '*.wim' '*.xar' '*.vhd'
                7z x $file
            case '*.xz'
                unxz $file
            case '*.exe'
                cabextract $file
            case '*.cpio'
                cpio -id <$file
            case '*.cba' '*.ace'
                unace x $file
            case '*.zpaq'
                zpaq x $file
            case '*.arc'
                arc e $file
            case '*.cso'
                ciso 0 $file "$file.iso"; and extract "$file.iso"; and rm -f $file
            case '*.zlib'
                zlib-flate -uncompress <$file >(string replace -r '\.zlib$' '' $file); and rm -f $file
            case '*.dmg'
                set mnt_dir (mktemp -d)
                hdiutil mount $file -mountpoint $mnt_dir
                echo "Mounted at: $mnt_dir"
            case '*.tar.zst'
                tar -I zstd -xvf $file
            case '*.zst'
                zstd -d $file
            case '*'
                echo "Error: Unsupported file format for '$file'."
                set failed_files $failed_files $file
                continue
        end

        if test $status -eq 0
            set success_files $success_files $file
        else
            set failed_files $failed_files $file
        end
    end

    if test (count $success_files) -gt 0
        echo "Successfully extracted files:"
        for file in $success_files
            echo " - $file"
        end
    end

    if test (count $failed_files) -gt 0
        echo "Failed to extract files:"
        for file in $failed_files
            echo " - $file"
        end
    end
end

function compress -d "All in one compress"
    if test (count $argv) -lt 2
        echo "Usage: compress <source1> <source2> ... <destination>"
        echo "Supported formats: .tar.gz, .tgz, .tar.bz2, .tbz2, .tar.xz, .txz, .tar, .gz, .bz2, .zip, .rar, .7z, .xz, .lzma, .Z, .zst"
        return 1
    end

    set destination $argv[-1]
    set sources $argv[1..-2]

    for source in $sources
        if not test -e $source
            echo "Error: Source '$source' does not exist."
            return 1
        end
    end

    switch $destination
        case '*.tar.gz' '*.tgz'
            tar -czf $destination $sources
        case '*.tar.bz2' '*.tbz2'
            tar -cjf $destination $sources
        case '*.tar.xz' '*.txz'
            tar -cJf $destination $sources
        case '*.tar'
            tar -cf $destination $sources
        case '*.gz'
            if test (count $sources) -ne 1
                echo "Error: .gz format only supports a single file."
                return 1
            end
            gzip -c $sources[1] >$destination
        case '*.bz2'
            if test (count $sources) -ne 1
                echo "Error: .bz2 format only supports a single file."
                return 1
            end
            bzip2 -c $sources[1] >$destination
        case '*.xz'
            if test (count $sources) -ne 1
                echo "Error: .xz format only supports a single file."
                return 1
            end
            xz -c $sources[1] >$destination
        case '*.lzma'
            if test (count $sources) -ne 1
                echo "Error: .lzma format only supports a single file."
                return 1
            end
            lzma -c $sources[1] >$destination
        case '*.Z'
            if test (count $sources) -ne 1
                echo "Error: .Z format only supports a single file."
                return 1
            end
            compress -c $sources[1] >$destination
        case '*.zip'
            zip -r $destination $sources
        case '*.rar'
            rar a $destination $sources
        case '*.7z'
            7z a $destination $sources
        case '*.tar.zst'
            tar -I zstd -cf $destination $sources
        case '*.zst'
            if test (count $sources) -ne 1
                echo "Error: .zst format only supports a single file."
                return 1
            end
            zstd -c $sources[1] >$destination
        case '*'
            echo "Error: Unsupported compression format for '$destination'."
            return 1
    end

    echo "Compression complete: $destination"
end

function batfollow -a filename -d "bat with tail -f"
    tail -f $filename | bat --paging=never -l log
end

function set_display -a display_num screen -d "set env DISPLAY"
    if test -z $display_num
        set display_num 0
    end
    if test -z $screen
        set screen 0
    end
    set ip (echo $SSH_CLIENT | awk '{print $1}')
    set -gx DISPLAY "$ip:$display_num.$screen"
end

function cargo_cache_clean -d "clean cargo cache"
    cargo cache --remove-dir all
end

function sudofunc -d "Run a function with sudo"
    if test (count $argv) -eq 0
        echo "Usage: sudofunc <function_name> [args...]"
        return 1
    end

    set function_name $argv[1]
    set args $argv[2..-1]

    if not functions -q $function_name
        echo "Error: Function '$function_name' does not exist."
        return 1
    end

    sudo fish -c "$function_name $args"
end
