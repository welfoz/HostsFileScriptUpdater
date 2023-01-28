# Hosts file updater

## Motivation

I use this script to block too distracting websites like youtube, twitter, linkedin, mails, facebook, etc. when I'm working.

I combine it with task scheduler to automatically block the websites at a certain time and unblock them at another time.

<br>

## Description

This is a simple Powershell script to add or remove a list of hostnames and ip's from your hosts file.

The host file is used to map hostnames to ip addresses. This is useful when you want to block websites or redirect them.

The host file is located in the following location:

```powershell
C:\Windows\System32\drivers\etc\hosts
```

<br>

## Requirements

- Powershell
- Administrator privileges (updating the hosts file requires admin privileges)

<br>

## Usage

The script can be used in the following way:

```powershell
./updateHosts.ps1 add <filename>
./updateHosts.ps1 remove <filename>
./updateHosts.ps1 show
```

### Filename requirements: 
It has to be a text file in the same format as the hosts file:

```text
ip hostname
```

```text
127.0.0.1 youtube.com
127.0.0.1 linkedin.com
127.0.0.1 twitter.com
...
```

## Usage examples

```powershell
./updateHosts.ps1 add hosts.txt
```

```powershell
./updateHosts.ps1 remove hosts.txt
```

```powershell
./updateHosts.ps1 show
```

##

Inspire by: 
https://gist.github.com/markembling/173887