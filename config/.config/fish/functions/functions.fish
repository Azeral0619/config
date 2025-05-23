set -x MIRROR_TORCH_CONDA https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/linux-64/
set -x MIRROR_PIP https://pypi.tuna.tsinghua.edu.cn/simple
set -x MIRROR_TORCH_PIP https://mirrors.aliyun.com/pytorch-wheels

function MMCV -a cuda_version torch_version -d "Return MMCV download url that fits cuda_version and torch_version"
    # 检查参数数量
    if test (count $argv) -ne 2
        echo "Usage: MMCV <cuda_version> <torch_version>"
        echo "Example: MMCV cuda11.8 torch2.1"
        return 1
    end

    # 解析参数
    set cuda_version (string replace -a 'cuda' 'cu' (string replace -a '.' '' $cuda_version))

    # 构造下载链接
    set url "https://download.openmmlab.com/mmcv/dist/$cuda_version/$torch_version/index.html"

    # 检查链接有效性
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
        echo "Usage: extract <file1 > < file2 >..."
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
            case '*.tar.gz' '*.tgz'
                tar -xzf $file
            case '*.tar.bz2' '*.tbz2'
                tar -xjf $file
            case '*.tar.xz' '*.txz'
                tar -xJf $file
            case '*.tar'
                tar -xf $file
            case '*.gz'
                gunzip $file
            case '*.bz2'
                bunzip2 $file
            case '*.zip'
                unzip $file
            case '*.rar'
                unrar x $file
            case '*.7z'
                7z x $file
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
        echo "Usage: compress <source1 > < source2 >... <destination >"
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
        case '*.zip'
            zip -r $destination $sources
        case '*.rar'
            rar a $destination $sources
        case '*.7z'
            7z a $destination $sources
        case '*'
            echo "Error: Unsupported compression format for '$destination'."
            return 1
    end

    echo "Compression complete: $destination"
end

function batfollow -a filename -d "bat with tail -f"
    tail -f $filename | bat --paging=never -l log
end

function set_display -a _display screen -d "set env DISPLAY"
    if test -z $_display
        set _display 0
    end
    if test -z $screen
        set screen 0
    end
    set ip (who | awk '{print $5}' | tr -d '()' | head -n 1)
    set -gx DISPLAY "$ip:$_display.$screen"
end
