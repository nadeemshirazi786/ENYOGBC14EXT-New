table 51014 "Custom Record Extension"
{
    fields
    {
        field(1; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(2; "Source Subtype"; Enum CustomRecExt)
        {
            Caption = 'Source Subtype';
        }
        field(3; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
        }
        field(4; "Source Ref. No."; Integer)
        {
            Caption = 'Source Ref. No.';
        }
        field(5; "Version No."; Integer)
        {
            Caption = 'Version No.';
        }
        field(6; "Doc. No. Occurrence"; Integer)
        {
            Caption = 'Doc. No. Occurrence';
        }
        field(100; "1st Room No."; Integer)
        {
        }
        field(101; "1st Room Quantity"; Integer)
        {
        }
        field(102; "2nd  Room No."; Integer)
        {
        }
        field(103; "2nd Room Quantity"; Integer)
        {
        }
        field(104; "3rd Room No."; Integer)
        {
        }
        field(105; "3rd Room Quantity"; Integer)
        {
        }
        field(106; "4th Room No."; Integer)
        {
        }
        field(107; "4th Room Quantity"; Integer)
        {
        }
        field(108; "5th Room No."; Integer)
        {
        }
        field(109; "5th Room Quantity"; Integer)
        {
        }
        field(110; "6th Room No."; Integer)
        {
        }
        field(111; "6th Room Quantity"; Integer)
        {
        }
        field(50000; "Authorized Amount"; Decimal)
        {

        }
        field(50001; "Cash Applied (Other)"; Decimal)
        {

        }
        field(50002; "Cash Applied (Current)"; Decimal)
        { }
        field(50003; "Cash Tendered"; Decimal)
        { }
        field(50004; "Entered Amount to Apply"; Decimal)
        { }
        field(50005; "Change Due"; Decimal)
        {

        }
    }

    keys
    {
        key(Key1; "Source Type", "Source Subtype", "Source ID", "Version No.", "Doc. No. Occurrence", "Source Ref. No.")
        {
            Clustered = true;
        }
    }
    var
        grecSalesLine: Record "Sales Line";
}

