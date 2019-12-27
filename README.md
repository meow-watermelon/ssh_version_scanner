# ssh_version_scanner

**Intro**

ssh_version_scanner is a small tool to detect and return the SSH server version string from a target host.

**Usage**

```
./ssh-version-scanner.pl --host <hostname> [--port <SSH server port>] [--timeout <connection timeout>]

DEFAULT SSH SERVER PORT: 22
DEFAULT CONNECTION TIMEOUT: 5 secs
```

**Tech Details**

SSH server sends out the server string ended with `0xD 0xA (\r\n)` immediately once the TCP handshake is done. This utility sends a TCP `RST` packet to eliminate the connection once the SSH server string is fetched. This would 1). reduce the number of packets to detect the SSH version; 2). no `TIME_WAIT` socket state.

**SSH Server String Explanation**

`SSH-2.0-OpenSSH_8.1`

*SSH*: server string prefix
*2.0*: SSH protocol version
*OpenSSH_8.1*: SSH server software name and version
