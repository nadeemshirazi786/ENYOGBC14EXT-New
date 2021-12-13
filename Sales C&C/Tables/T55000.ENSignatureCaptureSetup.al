table 55000 "EN Signature Capture Setup"
{

    fields
    {
        field(10; "Primary Key"; Code[10])
        {
        }
        field(20; "Penware Program Directory"; Text[50])
        {
        }
        field(30; "Penware Output Directory"; Text[50])
        {
        }
        field(40; "2Bitmap Program Directory"; Text[50])
        {
        }
        field(50; "2Bitmap Output Directory"; Text[50])
        {
        }
        field(60; "Use Signature Capture"; Boolean)
        {
        }
        field(70; "TopazCap Directory"; Text[50])
        {
        }
        field(80; "Use Topaz Capture"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

