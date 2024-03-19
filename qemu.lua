-- Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

function hello()
    print('hello')
end

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

    execv_args = {
        '-M', 'virt',
        '-display', 'none',
        '-serial', 'stdio',
        '-bios', 'none',
        '-kernel', binary(name)
    }

    for i, v in ipairs(opts.extra_args) do
        table.insert(execv_args, v)
    end

    os.execv(executable(), execv_args)
end

