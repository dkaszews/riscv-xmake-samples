-- Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

set_xmakever('2.9.1')
set_defaultmode('debug')
set_allowedmodes('debug')
set_defaultplat('unknown-elf')
set_allowedplats('unknown-elf')
set_defaultarchs('rv64g')
set_allowedarchs('rv64g', 'rv32g')
add_rules('mode.debug')


toolchain('riscv64-unknown-elf')
    set_kind('standalone')
    set_toolset('cc', 'riscv64-unknown-elf-gcc')
    set_toolset('cxx', 'riscv64-unknown-elf-g++')
    -- TODO: cannot find known tool script for as
    set_toolset('as', 'riscv64-unknown-elf-gcc')
    set_toolset('strip', 'riscv64-unknown-elf-strip')
    set_toolset('ld', 'riscv64-unknown-elf-ld')
    set_toolset('ar', 'riscv64-unknown-elf-ar')
    add_asflags('-nostartfiles')
    add_ldflags('-nostdlib')

    on_load(function (toolchain)
        function add_asflags(flags)
            toolchain:add('asflags', flags)
        end

        add_asflags('-march=' .. get_config('arch'))
        add_asflags('-Xassembler --defsym -Xassembler')
        add_asflags(('ARCH_%s=1'):format(get_config('arch'):upper()))

        if is_arch('rv64g') then
            add_asflags('-mabi=lp64')
        elseif is_arch('rv32g') then
            add_asflags('-mabi=ilp32')
        end
    end)


function target_asm(name)
    target(name)
        set_kind('binary')
        set_default(false)
        set_toolchains('riscv64-unknown-elf')
        add_files(('src/%s/**.s'):format(name))
        add_includedirs(('src/%s'):format(name))
        add_files('link/$(arch).ld')
        add_ldflags('--library-path link', { force = true })

        on_run(function (target)
            import('qemu').exec(name)
        end)

        -- TODO: maybe migrate all logic to lua?
        add_tests('default', { runargs = { name = name } })
        on_test(function (target, opt)
            runner = ('%s/test/run.sh'):format(os.projectdir())
            test = ('%s/test/%s'):format(os.projectdir(), opt.runargs.name)
            return os.execv(runner, { test }, { try = true }) == 0
        end)
    target_end()
end


function target_phony(name, runner)
    target(name)
        set_kind('phony')
        set_default(false)
        -- TODO: 'toolchain not found 'error' without this
        set_toolchains('gcc')
        -- TODO: wrapping `runner` in closure causes missing `import` error
        on_run(runner)
    target_end()
end


target_asm('hello')


target_phony('gdb', function (target)
    import('qemu')
    qemu.exec(qemu.proxy(target), { extra_args = { '-s', '-S' } })
end)


target_phony('attach', function (target)
    import('core.base.signal')
    import('qemu')

    init = 'target remote localhost:1234'
    multiarch = os.iorun('sh -c "which gdb-multiarch || true"'):len() ~= 0
    exe = multiarch and 'gdb-multiarch' or 'gdb'

    signal.register(signal.SIGINT, function () end)
    os.execv(exe, { qemu.binary(qemu.proxy(target)), '-ex', init })
    signal.reset(signal.SIGINT)
end)


target_phony('ci', function (target)
    import('qemu')
    status = qemu.exec(qemu.proxy(target), { exec_options = { try = true } })
    os.exit(status)
end)

