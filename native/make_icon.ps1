$ErrorActionPreference = 'Stop'
$out = Join-Path $PSScriptRoot 'PortableAppsStart.ico'
$frames = @(16, 32, 48)
$payloads = [System.Collections.Generic.List[byte[]]]::new()
foreach ($n in $frames) {
    $pixels = [byte[]]::new($n * $n * 4)
    $put = { param($x,$y,$r,$g,$b,$a=255)
        if ($x -ge 0 -and $y -ge 0 -and $x -lt $n -and $y -lt $n) {
            $i = (($n - 1 - $y) * $n + $x) * 4
            $pixels[$i] = [byte]$b; $pixels[$i+1] = [byte]$g; $pixels[$i+2] = [byte]$r; $pixels[$i+3] = [byte]$a
        }
    }
    $insideRoundRect = { param($x,$y,$left,$top,$right,$bottom,$radius)
        if ($x -lt $left -or $x -ge $right -or $y -lt $top -or $y -ge $bottom) { return $false }
        $cx = if ($x -lt $left+$radius) {$left+$radius} elseif ($x -ge $right-$radius) {$right-$radius-1} else {$x}
        $cy = if ($y -lt $top+$radius) {$top+$radius} elseif ($y -ge $bottom-$radius) {$bottom-$radius-1} else {$y}
        return (($x-$cx)*($x-$cx)+($y-$cy)*($y-$cy) -le $radius*$radius)
    }
    $scale = $n / 32.0
    for ($y=0; $y -lt $n; $y++) { for ($x=0; $x -lt $n; $x++) {
        $u=[int][Math]::Floor($x/$scale); $v=[int][Math]::Floor($y/$scale)
        $body=&$insideRoundRect $u $v 4 5 28 30 5
        $neck=&$insideRoundRect $u $v 10 2 22 9 3
        if ($body -or $neck) { & $put $x $y 224 238 250 255 }
        if (($u -ge 4 -and $u -lt 28 -and $v -ge 5 -and $v -lt 30) -or ($u -ge 10 -and $u -lt 22 -and $v -ge 2 -and $v -lt 9)) {
            if (-not (&$insideRoundRect ($u-1) $v 4 5 28 30 5) -or -not (&$insideRoundRect ($u+1) $v 4 5 28 30 5) -or -not (&$insideRoundRect $u ($v-1) 4 5 28 30 5) -or -not (&$insideRoundRect $u ($v+1) 4 5 28 30 5)) { & $put $x $y 183 208 233 255 }
        }
        $tiles=@(@(8,10),@(17,10),@(8,19),@(17,19)); $k=0
        foreach($t in $tiles) {
            $on=(&$insideRoundRect $u $v $t[0] $t[1] ($t[0]+7) ($t[1]+7) 1)
            if($on){$colors=@(@(44,142,238),@(111,185,242),@(111,185,242),@(160,210,248));$c=$colors[$k];&$put $x $y $c[0] $c[1] $c[2] 255}
            $k++
        }
    }}
    $mask=[byte[]]::new([int]([Math]::Ceiling($n/32.0)*4*$n))
    $ms=[IO.MemoryStream]::new(); $bw=[IO.BinaryWriter]::new($ms)
    $bw.Write([uint32]40);$bw.Write([int32]$n);$bw.Write([int32]($n*2));$bw.Write([uint16]1);$bw.Write([uint16]32)
    $bw.Write([uint32]0);$bw.Write([uint32]$pixels.Length);$bw.Write([int32]0);$bw.Write([int32]0);$bw.Write([uint32]0);$bw.Write([uint32]0)
    $bw.Write($pixels);$bw.Write($mask);$bw.Flush();$payloads.Add($ms.ToArray());$bw.Dispose();$ms.Dispose()
}
$ms=[IO.MemoryStream]::new();$bw=[IO.BinaryWriter]::new($ms)
$bw.Write([uint16]0);$bw.Write([uint16]1);$bw.Write([uint16]$frames.Count)
$offset=6+16*$frames.Count
for($i=0;$i -lt $frames.Count;$i++){
    $n=$frames[$i];$bw.Write([byte]$n);$bw.Write([byte]$n);$bw.Write([byte]0);$bw.Write([byte]0);$bw.Write([uint16]1);$bw.Write([uint16]32)
    $bw.Write([uint32]$payloads[$i].Length);$bw.Write([uint32]$offset);$offset+=$payloads[$i].Length
}
foreach($p in $payloads){$bw.Write($p)};$bw.Flush();[IO.File]::WriteAllBytes($out,$ms.ToArray());$bw.Dispose();$ms.Dispose()
Write-Host "Created $out"
