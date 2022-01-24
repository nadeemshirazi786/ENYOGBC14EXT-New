table 14229803 "PM Resource ELA"
{
    DrillDownPageID = "PM Proc. Equipment Req. ELA";
    LookupPageID = "PM Proc. Equipment Req. ELA";

    fields
    {
        field(1; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header ELA".Code;
        }
        field(2; "Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header ELA"."Version No." WHERE(Code = FIELD("PM Procedure Code"));
        }
        field(3; "PM Procedure Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
            Description = 'DO NOT USE Field No. 5';
        }
        field(10; Type; Option)
        {
            OptionMembers = Equipment,"Fixed Asset",Resource;
        }
        field(11; "No."; Code[20])
        {
            // TableRelation = IF (Type = CONST (Equipment)) "Quality Measure".Field1
            // ELSE
            // IF (Type = CONST ("Fixed Asset")) "Fixed Asset"."No."
            // ELSE
            // IF (Type = CONST (Resource)) Resource."No.";

            trigger OnValidate()
            begin
                if "No." <> '' then begin
                    case Type of
                        // Type::Equipment:
                        //     begin
                        //         grecPMWOResource.GET("No.");
                        //         Description := grecPMWOResource.Description;
                        //     end;
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
        key(Key1; "PM Procedure Code", "Version No.", "PM Procedure Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckPMHeaderStatus;

        if HasLinks then
            DeleteLinks;
    end;

    trigger OnInsert()
    begin
        CheckPMHeaderStatus;
    end;

    trigger OnModify()
    begin
        CheckPMHeaderStatus;
    end;

    trigger OnRename()
    begin
        CheckPMHeaderStatus;
    end;

    var
        //grecPMWOResource: Record Table23019207;
        grecFixedAsset: Record "Fixed Asset";
        grecResource: Record Resource;

    [Scope('Internal')]
    procedure CheckPMHeaderStatus()
    var
        lrecPMProc: Record "PM Procedure Header ELA";
    begin
        lrecPMProc.Get("PM Procedure Code", "Version No.");
        lrecPMProc.CheckStatus;
    end;

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

