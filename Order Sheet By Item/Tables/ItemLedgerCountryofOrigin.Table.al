table 14228813 "Item Ledger Country of Origin"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF02278AC
    //   20090213
    //     - new object
    // 
    //   20090616
    //     - add County Code table relation to new County of Origin table

    Caption = 'Item Ledger Country of Origin';

    fields
    {
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(20; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(30;"Serial No.";Code[20])
        {
            Caption = 'Serial No.';

            trigger OnLookup()
            var
            ItemTrackingMgt:Codeunit "Item Tracking Management";
            begin
                ItemTrackingMgt.LookupLotSerialNoInfo("Item No.","Variant Code",0,"Serial No.");
            end;
        }
        field(40;"Lot No.";Code[20])
        {
            Caption = 'Lot No.';

            trigger OnLookup()
            var
            ItemTrackingMgt:Codeunit "Item Tracking Management";
            begin
                ItemTrackingMgt.LookupLotSerialNoInfo("Item No.","Variant Code",1,"Lot No.");
            end;
        }
        field(60;"Country/Region Code";Code[10])
        {
            Caption = 'Country/Region Code';
            NotBlank = true;
            TableRelation = "Country/Region";
        }
        field(70;"County Code";Code[10])
        {
            Caption = 'State Code';
            TableRelation = County.Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(500;"Inventory Country of Origin";Boolean)
        {
            CalcFormula = Exist("Item Ledger Country of Origin" WHERE ("Item No."=FIELD("Item No."), "Variant Code"=FIELD("Variant Code"), "Serial No."=FIELD("Serial No."), "Lot No."=FIELD("Lot No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        
    }
    

    keys
    {
        key(Key1;"Item No.","Variant Code","Serial No.","Lot No.","Country/Region Code","County Code")
        {
            Clustered = true;
        }
    }


    
}


