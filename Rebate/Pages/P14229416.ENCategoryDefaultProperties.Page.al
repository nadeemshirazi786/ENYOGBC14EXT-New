page 14229416 "Category Def. Properties ELA"
{

    // ENRE1.00 2021-09-08 AJ
    //   ENRE1.00
    //     rem deprecated fields
    // 
    // ENRE1.00
    //   ENRE1.00 - modified jmdoFormatValue, when attempt to insert new gcarValue has no value so error occurs
    // 
    // ENRE1.00
    //   ENRE1.00 - Modified Function
    //              - jmdoFormatValue
    // 
    // ENRE1.00 - modified jmdoCodePropertyLookup from  EXIT(gvarValue) to EXIT(gtxtValue), due to runtime error
    // ENRE1.00 - clear gtxtValue when new record


    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Category Default Property ELA";

    layout
    {
        area(content)
        {
            repeater(Control1000000000)
            {
                ShowCaption = false;
                field("Category Code"; "Category Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Property Code"; "Property Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PropertyCodeOnAfterValidate;
                    end;
                }
                field("Property Group Code"; "Property Group Code")
                {
                    ApplicationArea = All;
                }
                field("Value Type"; "Value Type")
                {
                    ApplicationArea = All;
                }
                field(Value; gtxtValue)
                {
                    ApplicationArea = All;
                    Caption = 'Value';

                    trigger OnAssistEdit()
                    begin
                        if "Value Type" = "Value Type"::Code then begin
                            gvarValue := jmdoCodePropertyLookup;
                            jmdoValidateValue(gvarValue);
                            gtxtValue := Format(gvarValue);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        gvarValue := gtxtValue;
                        jmdoValidateValue(gvarValue);
                        gtxtValueOnAfterValidate;
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Decimal Min"; "Decimal Min")
                {
                    ApplicationArea = All;
                    Editable = "Decimal MinEditable";
                }
                field("Decimal Max"; "Decimal Max")
                {
                    ApplicationArea = All;
                    Editable = "Decimal MaxEditable";
                }
                field("Default Property Value"; "Default Property Value")
                {
                    ApplicationArea = All;
                }
                field("Value Posting"; "Value Posting")
                {
                    ApplicationArea = All;
                }
                field("Required Nutirient Information"; "Required Nutirient Information")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        jmdoFormatValue;
    end;

    trigger OnInit()
    begin
        "Decimal MaxEditable" := true;
        "Decimal MinEditable" := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        //<ENRE1.00>
        gvarValue := '';
        gtxtValue := '';
        //</ENRE1.00>
    end;

    var
        gtxtValue: Text[250];
        gvarValue: Variant;
        [InDataSet]
        "Decimal MinEditable": Boolean;
        [InDataSet]
        "Decimal MaxEditable": Boolean;


    procedure jmdoFormatValue()
    var
        lrecCategoryProp: Record "Category Default Property ELA";
    begin
        "Decimal MinEditable" := "Value Type" = "Value Type"::Decimal;
        "Decimal MaxEditable" := "Value Type" = "Value Type"::Decimal;

        //<ENRE1.00>
        Clear(gvarValue);
        Clear(gtxtValue);
        //</11732SHR>

        if lrecCategoryProp.Get("Category Code", "Line No.") then begin
            case "Value Type" of
                "Value Type"::Boolean:
                    begin
                        gvarValue := Format(lrecCategoryProp."Boolean Value");
                    end;
                "Value Type"::Code:
                    gvarValue := lrecCategoryProp."Code Value";
                "Value Type"::Text:
                    gvarValue := lrecCategoryProp."Text Value";
                "Value Type"::Decimal:
                    gvarValue := lrecCategoryProp."Decimal Value";
                //<ENRE1.00>
                "Value Type"::Percent:
                    gvarValue := lrecCategoryProp."Decimal Value";
                //</ENRE1.00>
                "Value Type"::Time:
                    gvarValue := lrecCategoryProp."Time Value";
                "Value Type"::Date:
                    begin
                        gvarValue := Format(lrecCategoryProp."Date Value");
                    end;
            end;
            //<ENRE1.00>
        end else begin
            gvarValue := '';
            //</ENRE1.00>
        end;

        gtxtValue := Format(gvarValue);
    end;


    procedure jmdoCodePropertyLookup(): Code[10]
    var
        lfrmCodeProperty: Page "Code Property Values ELA";
        lrecCodePropValue: Record "Code Property Value ELA";
    begin
        lrecCodePropValue.SetRange("Property Code", Rec."Property Code");
        lfrmCodeProperty.SetTableView(lrecCodePropValue);
        Clear(lrecCodePropValue);
        lfrmCodeProperty.LookupMode := true;
        if lfrmCodeProperty.RunModal = ACTION::LookupOK then begin
            lfrmCodeProperty.GetRecord(lrecCodePropValue);
            exit(lrecCodePropValue.Code);
        end else
            exit(gtxtValue);
    end;

    local procedure PropertyCodeOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure gtxtValueOnAfterValidate()
    begin
        CurrPage.Update;
    end;
}

