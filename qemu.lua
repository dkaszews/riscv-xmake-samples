-- Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

function executable()
    if is_arch('rv64g') then
        return 'qemu-system-riscv64'
    elseif is_arch('rv32g') then
        return 'qemu-system-riscv32'
    else
        raise('Unsupported arch')
    end
end


function binary(name)
    return ('%s/build/%s/%s/%s/%s'):format(
        os.projectdir(),
        get_config('plat'),
        get_config('arch'),
        get_config('mode'),
        name
    )
end


function exec(name, opts)
    opts = opts or {}
    opts.extra_args = opts.extra_args or {}
    opts.exec_options = opts.exec_options or {}

    execv_args = {
        '-M', 'virt',
        '-display', 'none',
        '-serial', 'stdio',
        '-bios', 'none',
        '-kernel', binary(name)
    }

    for i, v in ipairs(opts.extra_args) do
        -- TODO: why method call does not work?
        table.insert(execv_args, v)
    end

    return os.execv(executable(), execv_args, opts.exec_options)
end


function proxy(target)
    args = import('core.base.option').get('arguments')
    if not args then
        raise(('Usage: xmake run %s <target>'):format(target:name()))
    end
    return args[1]
end


function test(target, opts)
    local basedir = ('%s/test/%s'):format(os.projectdir(), opts.name)
    local tmpdir = ('%s/%s'):format(os.tmpdir(), opts.name)
    os.mkdir(tmpdir)

    local infile = basedir .. '/stdin.txt'
    local outfile = tmpdir .. '/outfile.log'
    local errfile = tmpdir .. '/errfile.log'

    local exec_options = {
        try = true,
        timeout = 5000,
        stdin = infile,
        stdout = outfile,
        stderr = errfile
    }
    local result = exec(target:name(), { exec_options = exec_options })
    local stdout = os.isfile(outfile) and io.readfile(outfile) or ''
    local stderr = os.isfile(errfile) and io.readfile(errfile) or ''

    function readfile_or(path, default)
        return os.isfile(path) and io.readfile(path) or default
    end

    local expected_result = tonumber(readfile_or(basedir .. '/result.txt', '0'))
    local expected_stdout = readfile_or(basedir .. '/stdout.txt', '')
    local expected_stderr = readfile_or(basedir .. '/stderr.txt', '')

    function print_indent(s)
        for line in tostring(s):gmatch('([^\n]*)') do
            print('    ' .. line)
        end
    end

    local pass = true
    function compare(name, expected, actual)
        if expected == actual then
            return
        end

        print('Mismatched %s, expected:')
        print_indent(expected)
        print('actual:')
        print_indent(actual)
        pass = false
    end

    compare('result', expected_result, result)
    compare('stdout', expected_stdout, stdout)
    compare('stderr', expected_stderr, stderr)
    return pass
end

