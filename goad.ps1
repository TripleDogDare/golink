<#
.SYNOPSIS
    Build your go project!
#>

$pkg = "polydawn.net/golink"
$name = [io.path]::GetFileNameWithoutExtension($pkg)
$name2 = ([io.fileinfo]$pkg).basename

$scriptpath = $MyInvocation.MyCommand.Path
$DIR = Split-Path $scriptpath
Write-host "My directory is $DIR"


function run_init () {
    Write-host "Run init"
    # return
    & git submodule update --init
    # Cheap trick to flag having a dev environment set up
    # mkdir -p $GOPATH\bin
    New-Item -ItemType Directory -Path "$GOPATH\bin" -Force

}

function run_test () {
    Write-host "Run test"
    # return
    & go test -v $pkgs
}

function run_fmt () {
    Write-host "Run fmt"
    # return
    & go fmt $pkgs
}

function run_clean () {
    Write-host "Run clean"
    # return
    Write-host "TODO: Kill it with fire"
}

function run_build () {
    Write-host "Run build"
    # return

    $bin_exists = Test-Path $GOPATH\bin
    if ( -not $bin_exists ) {
        Write-host "$(Join-Path $GOPATH bin) does not exist"
        run_init
    } else {
        Write-host "$(Join-Path $GOPATH bin) exists, skipping init"
    }

    # The `go install` command does not allow you to name the executable, but caches intermediate `.a` files in `.gopath/pkg`, making incremental builds instant. The `go build` command does not support this feature.
    # So, incremental build, then copy & rename wherever.
    & go install -v $pkg
    $exe_path = Join-Path $GOPATH bin
    $exe_path = Join-Path $exe_path $name
    $name_path = $(Join-Path . $name)
    if (Test-Path $exe_path) {
        Copy-Item $exe_path $name_path
    } else {
        $exe_path =  $exe_path + ".exe"
        $name_path =  $name_path + ".exe"
        Copy-Item $exe_path $name_path
    }
    Write-host "Copy $exe_path to $name_path"
}

function run_doc () {
    Write-host "Run doc"
    # return
    
    #Get all the packages
    if ($pkgs == ".\...") {
        $pkgs = Get-ChildItem -Path . -recurse | where PsIsContainer | Resolve-Path -Relative
    }

    # Print the docs
    for (package in $pkgs) {
        Write-host "==== $package ====\n"
        & godoc $pkg\$package
        Write-host "\n\n\n"
    }
}

$do_init  = $FALSE
$do_build = $FALSE
$do_clean = $FALSE
$do_test  = $FALSE
$do_fmt   = $FALSE
$do_doc   = $FALSE
$pkgs = @()

switch ($args) 
    {
        init  { $do_init  = $TRUE}
        build { $do_build = $TRUE}
        clean { $do_clean = $TRUE}
        test  { $do_test  = $TRUE}
        fmt   { $do_fmt   = $TRUE}
        doc   { $do_doc   = $TRUE}
        help  { Write-host "TODO: Display help!"}
        default {
            $pkgs += $_
        }
    }

# Decide if all packages will be compiled, or user-specified ones
if ( $pkgs.count -eq 0 ) {
    #All
    $pkgs=".\..."
} else {
    #Specified, expand array
    $pkgs="@pkgs"
}

cd $DIR
$BASEDIR = $PWD.Path
$GOPATH = "{0}\.gopath\" -f $PWD.Path
Set-Item Env:GOPATH $GOPATH

$link_path = $(Join-Path $GOPATH "src")
$link_path = $(Join-Path $link_path $pkg)
#Replace unix symlink with ntfs junction
if ($(Test-Path $link_path -PathType leaf)) {
    Write-host "Removing file $link_path"
    Remove-Item $link_path
    # cmd /c rmdir $link_path
    # [System.IO.Directory]::Delete($link_path,$true)
    Write-host "Make symlink $link_path -> $BASEDIR"
    cmd /c mklink /j "$link_path" "$BASEDIR"
    $link=Test-Path "$link_path"
    if ( -not $link ) {
        Write-host "Failed to create symlink"
        Write-Host -NoNewLine "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }
}

if ( $do_init ) {
    run_init
}

if ( $do_build ) {
    run_build
}

if ( $do_clean ) {
    run_clean
}

if ( $do_test ) {
    run_test
}

if ( $do_fmt ) {
    run_fmt
}

if ( $do_doc ) {
    run_doc
}

$did_something = $do_init -or $do_build -or $do_clean -or $do_test -or $do_fmt -or $do_doc
if (!$did_something) {
    run_build
}

#Pause
Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
