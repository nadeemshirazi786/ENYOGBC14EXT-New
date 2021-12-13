table 14229408 "Code Property Value ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00  - changed Code len to 30

    LookupPageID = "Code Property Values ELA";

    fields
    {
        field(1; "Property Code"; Code[20])
        {
            TableRelation = "Property ELA";
        }
        field(2; "Code"; Code[30])
        {
        }
        field(3; Description; Text[50])
        {
        }
        field(10; Picture; BLOB)
        {
            SubType = Bitmap;
        }
    }

    keys
    {
        key(Key1; "Property Code", "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        gcduFileMgt: Codeunit "File Management";
        grecBLOBref: Record TempBlob;
        gText000: Label 'Do you want to replace the existing picture?';
        gText001: Label 'Process cancelled.';
        gText002: Label 'Are you sure you want to delete the existing picture?';

    [Scope('Internal')]
    procedure picImport()
    begin
        if Picture.HasValue then
            if not Confirm(gText000, false) then
                Error(gText001);

        gcduFileMgt.BLOBImport(grecBLOBref, 'Import Picture');
        Picture := grecBLOBref.Blob;
        Modify;
    end;

    [Scope('Internal')]
    procedure picExport()
    begin
        if Picture.HasValue then begin
            grecBLOBref.Blob := Picture;
            gcduFileMgt.BLOBExport(grecBLOBref, 'picture.bmp', true);
        end;
    end;

    [Scope('Internal')]
    procedure picDelete()
    begin
        if Picture.HasValue then
            if Confirm(gText002) then begin
                Clear(Picture);
                Modify;
            end;
    end;
}

