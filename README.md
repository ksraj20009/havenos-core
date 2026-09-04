# HavenOS-core

From-scratch tiny OS: original boot sector + original kernel.
Not Linux. Not a fork. Not a rename.

```bash
make
qemu-system-i386 -drive format=raw,file=dist/havenos-core.img
```

Commands at `haven>`: help, about, echo, clear, mem, reboot, halt.
