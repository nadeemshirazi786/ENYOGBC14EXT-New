table 14229108 "EN Invt. Posting Buffer"
{
    

    Caption = 'Invt. Posting Buffer';
    ReplicateData = false;

    fields
    {
        field(1; "Account Type"; Option)
        {
            Caption = 'Account Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Inventory (Interim),Invt. Accrual (Interim),Inventory,WIP Inventory,Inventory Adjmt.,Direct Cost Applied,Overhead Applied,Purchase Variance,COGS,COGS (Interim),Material Variance,Capacity Variance,Subcontracted Variance,Cap. Overhead Variance,Mfg. Overhead Variance,,,,,,Writeoff (Company),Writeoff (Vendor),Invt. Accrual-EC (Interim),Direct Cost Applied-EC,ABC Direct,ABC Overhead';
            OptionMembers = "Inventory (Interim)","Invt. Accrual (Interim)",Inventory,"WIP Inventory","Inventory Adjmt.","Direct Cost Applied","Overhead Applied","Purchase Variance",COGS,"COGS (Interim)","Material Variance","Capacity Variance","Subcontracted Variance","Cap. Overhead Variance","Mfg. Overhead Variance",,,,,,"Writeoff (Company)","Writeoff (Vendor)","Invt. Accrual-EC (Interim)","Direct Cost Applied-EC","ABC Direct","ABC Overhead";
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
        }
        field(3; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            DataClassification = SystemMetadata;
        }
        field(4; "Dimension Entry No."; Integer)
        {
            Caption = 'Dimension Entry No.';
            DataClassification = SystemMetadata;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(6; "Amount (ACY)"; Decimal)
        {
            Caption = 'Amount (ACY)';
            DataClassification = SystemMetadata;
        }
        field(7; "Interim Account"; Boolean)
        {
            Caption = 'Interim Account';
            DataClassification = SystemMetadata;
        }
        field(8; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
        field(9; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
        }
        field(10; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = SystemMetadata;
        }
        field(11; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = SystemMetadata;
        }
        field(12; Negative; Boolean)
        {
            Caption = 'Negative';
            DataClassification = SystemMetadata;
        }
        field(13; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(14; "Bal. Account Type"; Option)
        {
            Caption = 'Bal. Account Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Inventory (Interim),Invt. Accrual (Interim),Inventory,WIP Inventory,Inventory Adjmt.,Direct Cost Applied,Overhead Applied,Purchase Variance,COGS,COGS (Interim),Material Variance,Capacity Variance,Subcontracted Variance,Cap. Overhead Variance,Mfg. Overhead Variance,,,,,,Writeoff (Company),Writeoff (Vendor),Invt. Accrual-EC (Interim),Direct Cost Applied-EC,ABC Direct,ABC Overhead';
            OptionMembers = "Inventory (Interim)","Invt. Accrual (Interim)",Inventory,"WIP Inventory","Inventory Adjmt.","Direct Cost Applied","Overhead Applied","Purchase Variance",COGS,"COGS (Interim)","Material Variance","Capacity Variance","Subcontracted Variance","Cap. Overhead Variance","Mfg. Overhead Variance",,,,,,"Writeoff (Company)","Writeoff (Vendor)","Invt. Accrual-EC (Interim)","Direct Cost Applied-EC","ABC Direct","ABC Overhead";
        }
        field(15; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            DataClassification = SystemMetadata;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(37002660; "Additional Posting Code"; Code[20])
        {
            Caption = 'Additional Posting Code';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Posting Date", "Account Type", "Location Code", "Inventory Posting Group", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Dimension Set ID", "Additional Posting Code", Negative, "Bal. Account Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    procedure UseInvtPostSetup(): Boolean
    begin
        exit(
          "Account Type" in
          ["Account Type"::Inventory,
           "Account Type"::"Inventory (Interim)",
           "Account Type"::"Writeoff (Company)", // PR3.61.01
           "Account Type"::"Writeoff (Vendor)",  // PR3.61.01
           "Account Type"::"WIP Inventory",
           "Account Type"::"Material Variance",
           "Account Type"::"Capacity Variance",
           "Account Type"::"Subcontracted Variance",
           "Account Type"::"Cap. Overhead Variance",
           "Account Type"::"Mfg. Overhead Variance"]);
    end;

    [Scope('Internal')]
    procedure UseECPostingSetup(): Boolean
    begin
        // P8000466A
        exit(
          "Account Type" in
          ["Account Type"::"Invt. Accrual-EC (Interim)",
           "Account Type"::"Direct Cost Applied-EC"]);
    end;

    [Scope('Internal')]
    procedure UseABCDetail(): Boolean
    begin
        // P8000466A
        exit(
          "Account Type" in
          ["Account Type"::"ABC Direct",
           "Account Type"::"ABC Overhead"]);
    end;
}

