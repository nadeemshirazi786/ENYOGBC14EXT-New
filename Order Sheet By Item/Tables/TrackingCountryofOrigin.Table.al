table 14228818 "Tracking Country of Origin"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF02278AC
    //   20090225
    //     - new object
    // 
    //   20090325
    //     - add Source Prod. Order Line
    //     - add Source Prod. Order Line to PK
    // 
    //   20090327
    //     - add Source Batch Name
    //     - add Source Batch Name to PK
    // 
    //   20090401
    //     - add SetPointer fn (similar to Reservation Entry::SetPointer)
    // 
    //   20090616
    //     - add County Code table relation to new County of Origin table

    Caption = 'Tracking Country of Origin';

    fields
    {
        field(10; "Source Type"; Integer)
        {
            Caption = 'Source Type';
        }
        field(20; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
        }
        field(30; "Source No."; Code[20])
        {
            Caption = 'Source No.';
        }
        field(35; "Source Batch Name"; Code[20])
        {
            Caption = 'Source Batch Name';
        }
        field(40; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
        }
        field(50; "Source Prod. Order Line"; Integer)
        {
            Caption = 'Source Prod. Order Line';
        }
        field(60; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(70;"County Code";Code[10])
        {
            Caption = 'State Code';
            TableRelation = County.Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
        }
        field(110;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(120;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(130;"Serial No.";Code[20])
        {
            Caption = 'Serial No.';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupLotSerialNoInfo("Item No.","Variant Code",0,"Serial No.");
            end;
        }
        field(140;"Lot No.";Code[20])
        {
            Caption = 'Lot No.';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupLotSerialNoInfo("Item No.","Variant Code",1,"Lot No.");
            end;
        }
    }

    keys
    {
        key(Key1;"Source Type","Source Subtype","Source No.","Source Batch Name","Source Line No.","Source Prod. Order Line","Item No.","Variant Code","Serial No.","Lot No.","Country/Region Code","County Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";

    [Scope('Internal')]
    procedure SetPointer(precref: RecordRef)
    var
        lrecProdOrderLine: Record "Prod. Order Line";
        lrecItemJnlLine: Record "Item Journal Line";
        lrecProdComponent: Record "Prod. Order Component";
        ljftxt030: Label '%1: Unable to SetPointer from Table %2.';
    begin

        CASE precref.NUMBER OF
          DATABASE::"Prod. Order Line" : BEGIN
            precref.SETTABLE( lrecProdOrderLine );
            "Source Type" := DATABASE::"Prod. Order Line";
            "Source Subtype" := lrecProdOrderLine.Status;
            "Source No." := lrecProdOrderLine."Prod. Order No.";
            "Source Batch Name" := '';
            "Source Line No." := 0;
            "Source Prod. Order Line" := lrecProdOrderLine."Line No.";
          END;
          DATABASE::"Prod. Order Component" : BEGIN
            precref.SETTABLE( lrecProdComponent );
            "Source Type" := DATABASE::"Prod. Order Component";
            "Source Subtype" := lrecProdComponent.Status;
            "Source No." := lrecProdComponent."Prod. Order No.";
            "Source Batch Name" := '';
            "Source Line No." := lrecProdComponent."Line No.";
            "Source Prod. Order Line" := lrecProdComponent."Prod. Order Line No.";
          END;
          DATABASE::"Item Journal Line" : BEGIN
            precref.SETTABLE( lrecItemJnlLine );
            "Source Type" := DATABASE::"Item Journal Line";
            "Source Subtype" := lrecItemJnlLine."Entry Type";
            "Source No." := lrecItemJnlLine."Journal Template Name";
            "Source Batch Name" := lrecItemJnlLine."Journal Batch Name";
            "Source Line No." := lrecItemJnlLine."Line No.";
            "Source Prod. Order Line" := 0;
          END;
          ELSE BEGIN
            ERROR( ljftxt030, TABLECAPTION, FORMAT( precref.NUMBER ) );
          END;
        END;
    end;
}

