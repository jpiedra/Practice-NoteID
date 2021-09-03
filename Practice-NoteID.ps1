<# Script settings:
    DIFFICULTY - How long each note lasts (W,H,Q,E,S)
    INTERVAL - How much time between each loop (Seconds)
#>
Param
(
    [Parameter(Mandatory)]
    [ValidateSet("Easy","Medium","Hard",IgnoreCase = $true)]
    $Difficulty = "Easy",

    [Parameter(Mandatory)]
    [int]
    $Interval
)

# Initialize variables, forms and picture objects
$NoteDuration = "W"
[reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
$Form = New-Object system.Windows.Forms.Form
$pictureBox = new-object Windows.Forms.PictureBox

[System.Windows.Forms.Application]::EnableVisualStyles();
$pictureBox.Location = New-Object System.Drawing.Size(0,1)
$staticSize = New-Object System.Drawing.Size(275,275)

$pictureBox.Size = $staticSize
$Form.Location = $staticSize
$Form.Size = $staticSize
$Form.StartPosition = "Manual"
$Form.Visible = $false
$Form.Enabled = $true
$Form.Add_Shown({$Form.Activate()})

switch ($Difficulty)
{
    "Easy" { $NoteDuration = "W"; $Color = "Green" }
    "Medium" { $NoteDuration = "H"; $Color = "Yellow" }
    "Hard" { $NoteDuration = "Q"; $Color = "Red" }
}

While ($true) {
    Clear-Host

    # generate a note [http://sticksandstones.kstrom.com/appen.html]
    $Note = [char]$((65..71) | Get-Random -Count 1)

    # if it IS NOT b or e, give it 50% chance of becoming a sharp
    If ($Note -ne 'B' -and $Note -ne 'E') {
        If ([bool]$(0,1 | Get-Random)) { $Note += "#" }
    }

    Write-Host -ForegroundColor $Color -BackgroundColor Black "Play the note: $Note" 
    
    # render the corresponding image file
    $file = (get-item "C:\Users\JLP\Documents\Guitar\practice\diagrams\$($Note).png")
    $img = [System.Drawing.Image]::Fromfile($file);
    $pictureBox.Image = $img

    $Form.controls.add($pictureBox)
    $Form.Topmost = $True

    $rs = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $rs.Open()
    $rs.SessionStateProxy.SetVariable("Form", $Form)
    $data = [hashtable]::Synchronized(@{text=""})
    $rs.SessionStateProxy.SetVariable("data", $data)
    $p = $rs.CreatePipeline({ [void] $Form.ShowDialog()})
    $p.Input.Close()
    $p.InvokeAsync()

    $Note += $NoteDuration

    # play it [https://github.com/Duelr/Play-Notes]
    .\Play-Notes.ps1 -Notes $Note

    Start-Sleep -Seconds $Interval
}