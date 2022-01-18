table 23019263 "WO Resource"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    DrillDownPageID = 23019263;
    LookupPageID = 23019263;

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {
            TableRelation = Table23019260.Field1;
        }
        field(2; "PM Proc. Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header"."Version No." WHERE (Code = FIELD ("PM Procedure Code"));
        }
        field(3; "PM WO Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
        }
        field(5; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header".Code;
        }
        field(10; Type; Option)
        {
            OptionMembers = Equipment,"Fixed Asset",Resource;
        }
        field(11; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST (Equipment)) Table23019207.Field1
            ELSE
            IF (Type = CONST ("Fixed Asset")) "Fixed Asset"."No."
            ELSE
            IF (Type = CONST (Resource)) Resource."No.";

            trigger OnValidate()
            begin
                if "No." <> '' then begin
                    case Type of
                        Type::Equipment:
                            begin
                                grecPMWOResource.GET("No.");
                                Description := grecPMWOResource.Description;
                            end;
                        Type::"Fixed Asset":
                            begin
                                grecFixedAsset.Get("No.");
                                Description := grecFixedAsset.Description;
                            end;
                        Type::Resource:
                            begin
                                grecResource.Get("No.");
                                Description := grecResource.Name;
                                "Unit of Measure" := grecResource."Base Unit of Measure";
                                FindResUnitCost;
                            end;
                    end;
                end else begin
                    Quantity := 0;
                    "Unit Cost" := 0;
                    "Total Cost" := 0;
                    "Work Type Code" := '';
                    "Unit of Measure" := '';
                end;
            end;
        }
        field(12; Description; Text[50])
        {
        }
        field(20; Quantity; Decimal)
        {
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CalcTotalCost;
            end;
        }
        field(21; "Unit of Measure"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(22; "Work Type Code"; Code[10])
        {
            TableRelation = "Work Type";

            trigger OnValidate()
            begin
                if Type = Type::Resource then
                    FindResUnitCost;
            end;
        }
        field(25; "Unit Cost"; Decimal)
        {
            DecimalPlaces = 2 : 5;

            trigger OnValidate()
            begin
                CalcTotalCost;
            end;
        }
        field(26; "Total Cost"; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; "PM Work Order No.", "PM WO Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if HasLinks then
            DeleteLinks;
    end;

    var
        grecPMWOResource: Record Table23019207;
        grecFixedAsset: Record "Fixed Asset";
        grecResource: Record Resource;

    local procedure FindResUnitCost()
    var
        lrecResCost: Record "Resource Cost";
        lcduResFindUnitCost: Codeunit "Resource-Find Cost";
    begin
        if Type <> Type::Resource then
            exit;

        lrecResCost.Init;
        lrecResCost.Code := "No.";
        lrecResCost."Work Type Code" := "Work Type Code";
        lcduResFindUnitCost.Run(lrecResCost);
        Validate("Unit Cost", lrecResCost."Unit Cost");
    end;

    [Scope('Internal')]
    procedure CalcTotalCost()
    begin
        "Total Cost" := Round("Unit Cost" * Quantity);
    end;
}

