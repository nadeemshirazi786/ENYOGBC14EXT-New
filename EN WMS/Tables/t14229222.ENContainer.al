//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Conatiner (ID 14229222).
/// </summary>
/// 

//todo #22 @bilalb53 please make sure containers gets created from Purchase order.
table 14229222 "Container ELA"
{
    Caption = 'Conatiner';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger Onvalidate()
            begin
                IF "No." <> xRec."No." THEN BEGIN
                    GetWMSSetup;
                    NoSeriesMgt.TestManual(WMSSetup."Container Nos.");
                END;
            end;
        }
        field(2; "Closed"; Boolean)
        {
            // Caption = 'Container Status';
            DataClassification = ToBeClassified;
        }
        // field(3; "Shipment No."; Code[20])
        // {
        //     Caption = 'Shipment No.';
        //     DataClassification = ToBeClassified;
        // }
        field(4; "Document Status"; Enum "WMS Document Status ELA")
        {
            // Caption = 'Shipment Status';
            DataClassification = ToBeClassified;
        }
        field(5; "Load No."; Code[20])
        {
            Caption = 'Load No.';
            DataClassification = ToBeClassified;
        }
        field(6; "Location Code"; Code[20])
        {
            Caption = 'Location';
            TableRelation = Location;
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                ContainerContent: record "Container Content ELA";
            begin
                ContainerContent.reset;
                ContainerContent.SetRange("Container No.", "No.");
                if ContainerContent.FindSet() then
                    repeat
                        if ContainerContent."Location Code" <> "Location Code" then begin
                            ContainerContent."Bin Code" := '';
                            ContainerContent.Zone := '';
                            ContainerContent."Location Code" := "Location Code";
                            ContainerContent.Modify();
                        end;
                    until ContainerContent.Next() = 0;
            end;
        }
        field(7; "Container Type"; COde[20])
        {
            Caption = 'Container Type';
            TableRelation = "Conatiner Type ELA";
            DataClassification = ToBeClassified;

            // trigger OnValidate()
            // var
            //     ContainerType: record "EN Conatiner Type";
            // begin
            //     "Tare Weight" := ContainerType.
            // end;
        }
        field(8; "Parent Container No."; Code[20])
        {
            Caption = 'Parent Container No.';
            DataClassification = ToBeClassified;
        }
        field(9; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DataClassification = ToBeClassified;
        }
        field(10; "Tare Weight"; Decimal)
        {
            Caption = 'Tare Weight';
            DataClassification = ToBeClassified;
        }
        field(11; "Freight Charges"; Decimal)
        {
            Caption = 'Freight Charges';
            DataClassification = ToBeClassified;
        }
        field(12; "Direction"; Enum "WMS Trip Direction ELA")
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                /*    validate("Source Document Type");
                    if Direction = Direction::Inbound then begin
                        "Whse. Document Type" := "Whse. Document Type"::Receipt
                    end else begin
                        "Whse. Document Type" := "Whse. Document Type"::Shipment;
                    end;*/
            end;
        }
        /*  field(13; "Source Document Type"; Enum "EN WMS Source Doc Type")
          {
              DataClassification = ToBeClassified;
              trigger OnValidate()
              var
              begin
                  case "Source Document Type" of
                      "Source Document Type"::"Purchase Order":
                          begin
                              "Document Type" := 1;
                              Direction := Direction::Inbound;
                              "Whse. Document Type" := "Whse. Document Type"::Receipt;
                          end;

                      "Source Document Type"::"Sales Order":
                          begin
                              "Document Type" := 1;
                              Direction := Direction::Outbound;
                              "Whse. Document Type" := "Whse. Document Type"::Shipment;
                          end;
                  end;
                  // if "Source Document Type" = "Source Document Type"::"Purchase Order" then begin
                  //     "Document Type" := 1;
                  //     Direction := Direction::Inbound;
                  //     "Whse. Document Type" := "Whse. Document Type"::Receipt;
                  //end;
              end;
          }
          field(14; "Document Type"; Integer)
          {
              Editable = false;
              DataClassification = ToBeClassified;
          }

          field(15; "Document No."; Code[20])
          {
              TableRelation =
                 if ("Source Document Type" = const("Purchase Order")) "Purchase Header"."No." where("Document Type" = const(Order))
              else
              if ("Source Document Type" = const("Sales Order")) "Sales Header"."No." where("Document Type" = const(Order));
          }
          field(16; "Whse. Document Type"; Enum "EN Whse. Doc. Type")
          {
              // only use 1- receipt / 2- shipment
              DataClassification = ToBeClassified;
              trigger OnValidate()
              var
              begin

              end;
          }
          field(17; "Whse. Document No."; Code[20])
          {
              TableRelation = if ("Whse. Document Type" = const(Receipt)) "Warehouse Receipt Header"
              else
              if ("Whse. Document Type" = const(Shipment)) "Warehouse Shipment Header";

              trigger OnValidate()
              var
                  WhseRcptLine: Record "Warehouse Receipt Line";
              begin
                  if "Whse. Document Type" = "Whse. Document Type"::Receipt then begin
                      if "Document No." = '' then begin
                          WhseRcptLine.reset;
                          WhseRcptLine.SetRange("No.", "Whse. Document No.");
                          if WhseRcptLine.FindFirst() then begin
                              if WhseRcptLine."Source Type" = 39 then begin
                                  "Source Document Type" := "Source Document Type"::"Purchase Order";
                                  "Document Type" := 1;
                                  "Document No." := WhseRcptLine."Source No.";
                                  Direction := Direction::Inbound;
                              end;
                          end;
                      end;
                  end;
              end;
          }

          field(18; "Activity Type"; Enum "EN WMS Activity Type")
          {
              DataClassification = ToBeClassified;
          }

          field(19; "Activity No."; Code[20])
          {
              TableRelation = "Warehouse Activity Header"."No." where("Type" = const(2));
              DataClassification = ToBeClassified;
          }*/

        field(20; "Completed"; Boolean)
        {
            trigger OnValidate()
            var
            begin
                if Completed then
                    "Document Status" := "Document Status"::Completed;
            end;
        }

        /*  field(30; "Trip No."; code[20])
          {
              TableRelation = "EN Trip Load";
          }*/
        field(14229220; "Created On"; Datetime)
        {
            DataClassification = ToBeClassified;
        }
        field(14229221; "Created By"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        HasWMSSetup: boolean;
        WMSSetup: Record "WMS Setup ELA";

    trigger OnInsert()
    var
        ContStatus: enum "WMS Container Status ELA";
    begin
        IF "No." = '' THEN BEGIN
            GetWMSSetup();
            WMSSetup.TESTFIELD("Container Nos.");
            "No." := NoSeriesMgt.GetNextNo(WMSSetup."Container Nos.", 0D, TRUE);
        END;

        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        // validate("Source Document Type");
    end;

    trigger OnModify()
    begin
        // "Last Updated By" := userid;
        // "Last Updated On" := CurrentDateTime;
    end;

    trigger OnDelete()
    var
        ContainerContents: Record "Container Content ELA";
        "14229220": Label 'Unable to delete Container %1 as it is marked completed.';
    begin
        if Completed then
            Error(StrSubstNo("14229220", "No."));

        ContainerContents.SetRange("Container No.", "No.");
        ContainerContents.DeleteAll(true);
    end;

    local procedure GetWMSSetup()
    begin
        if NOT HasWMSSetup then begin
            WMSSetup.get;
            HasWMSSetup := true;
        end;
    end;

}
