//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Shipment Dashboard (ID 14229224).
/// </summary>
table 14229228 "Shipment Dashboard ELA"
{
    fields
    {
        field(1; Select; Boolean)
        {
            trigger OnValidate()
            var
                ShipDashBrd: Record "Shipment Dashboard ELA";
                ShipDashBrd2: Record "Shipment Dashboard ELA";
                QtyAvailable: Decimal;
                UseTrip: Boolean;
            begin
                UseTrip := false;
                if ("Trip No." <> '') then
                    UseTrip := true;

                ShipDashBrd.Reset;
                ShipDashBrd.SetRange("Locked By User ID", UserId);
                if (UseTrip) then
                    ShipDashBrd.SetFilter("Trip No.", '<>%1', "Trip No.")
                else
                    ShipDashBrd.SetFilter("Source No.", '<>%1', "Source No.");

                if ShipDashBrd.FindFirst then begin
                    if GuiAllowed then begin
                        //EN1.12
                        // if TransferHeader."Auto Pick" then
                        //     DeSelectOrder(ShipDashBrd."Source No.")
                        // else begin
                        if Confirm(StrSubstNo(TEXT14229225, ShipDashBrd."Source No.", ShipDashBrd."Source No.")) then
                            DeSelectOrder(ShipDashBrd."Trip No.", ShipDashBrd."Source No.", UseTrip)
                        else begin
                            Select := false;
                            exit;
                        end;
                    end;
                end else
                    DeSelectOrder(ShipDashBrd."Trip No.", ShipDashBrd."Source No.", UseTrip);
                // end;

                //<<EN1.18
                //IF CONFIRM(STRSUBSTNO(TEXT50005,ShipDashBrd."Source No.",ShipDashBrd."Source No.")) THEN BEGIN
                //  DeSelectOrder(ShipDashBrd."Source No.");
                //END ELSE BEGIN
                //  Select := FALSE;
                //  EXIT;
                //END;
                //>>EN1.18

                if Level = 0 then begin
                    if ("Locked By User ID" <> '') and ("Locked By User ID" <> UpperCase(UserId)) then
                        if not Confirm(StrSubstNo(TEXT14229223, "Source No.", xRec."Locked By User ID")) then begin
                            Select := xRec.Select;
                            exit;
                        end;

                    if Select then begin
                        "Locked By User ID" := UserId;
                        "Ship Action" := "Ship Action"::Fullfill;
                    end else begin
                        "Ship Action" := "Ship Action"::" ";
                        DeSelectOrder(ShipDashBrd."Trip No.", ShipDashBrd."Source No.", UseTrip);
                    end;

                    // WhseSetup.Get;
                    ShipDashBrd.Reset;
                    ShipDashBrd.SetRange("Parent ID", ID);
                    ShipDashBrd.SetRange(Level, 1);
                    if ShipDashBrd.FindSet then begin
                        repeat
                            ShipDashBrd.CalcFields("Qty. On Pick");
                            if Select then begin
                                if ShipDashBrd."Qty. Reqd." - (ShipDashBrd."Qty. On Pick" + ShipDashBrd."Picked Qty.") > 0 then begin
                                    QtyAvailable := 0;

                                    QtyAvailable := ShipDBMgt.GetQuantityAvailable(ShipDashBrd);
                                    //  message('qty avail%1',qtyavailable);
                                    if QtyAvailable >= ShipDashBrd."Qty. Reqd." then begin
                                        ShipDashBrd.Validate("Ship Action", ShipDashBrd."Ship Action"::Fullfill);
                                        if ShipDashBrd."Qty. Reqd." - (ShipDashBrd."Qty. On Pick" + ShipDashBrd."Picked Qty.") <> 0 then
                                            ShipDashBrd.Validate("Qty. Avail.", QtyAvailable);

                                        //ShipDashBrd.VALIDATE("Qty. To Ship",ShipDashBrd."Qty. Reqd." -
                                        // (ShipDashBrd."Qty. On Pick" + ShipDashBrd."Picked Qty."));
                                        if QtyAvailable >= (ShipDashBrd."Qty. Reqd." - (ShipDashBrd."Picked Qty." + ShipDashBrd."Qty. On Pick"))
                                        then begin
                                            ShipDashBrd."Short By Qty." := 0;
                                            ShipDashBrd."Back Order Qty." := 0;
                                        end;

                                        ShipDashBrd.Select := true;
                                        ShipDashBrd."Locked By User ID" := UserId;
                                    end else begin
                                        ShipDashBrd.Validate("Ship Action", ShipDashBrd."Ship Action"::"Back Order");
                                        ShipDashBrd.Validate("Qty. Avail.", QtyAvailable);
                                        //ShipDashBrd.VALIDATE("Qty. To Ship",QtyAvailable);
                                        ShipDashBrd."Short By Qty." := QtyAvailable -
                                          (ShipDashBrd."Qty. Reqd." -
                                            (ShipDashBrd."Qty. On Pick" + ShipDashBrd."Picked Qty."));
                                        ShipDashBrd."Back Order Qty." :=
                                          ShipDashBrd."Qty. Reqd." -
                                            (ShipDashBrd."Qty. On Pick" + ShipDashBrd."Picked Qty." + ShipDashBrd."Qty. To Ship");
                                        ShipDashBrd.Select := true;
                                        ShipDashBrd."Locked By User ID" := UserId;
                                    end;
                                end;
                            end else begin
                                ShipDashBrd.Validate("Qty. Avail.", 0);
                                ShipDashBrd."Qty. To Ship" := 0;
                                ShipDashBrd."Short By Qty." := 0;
                                ShipDashBrd."Back Order Qty." := 0;
                                ShipDashBrd.Validate("Ship Action", ShipDashBrd."Ship Action"::" ");
                                ShipDashBrd.Select := false;
                                ShipDashBrd."Locked By User ID" := '';
                            end;

                            ShipDashBrd.Modify(true);

                        until ShipDashBrd.Next = 0;
                    end;
                end else begin
                    if ("Locked By User ID" <> '') and ("Locked By User ID" <> UpperCase(UserId)) then
                        if not Confirm(StrSubstNo(TEXT14229224, "Source No.", "Item No.", "Locked By User ID")) then begin
                            Select := xRec.Select;
                            exit;
                        end;
                    CalcFields("Qty. On Pick");
                    if Select then begin
                        QtyAvailable := ShipDBMgt.GetQuantityAvailable(Rec);
                        if QtyAvailable >= "Qty. Reqd." then begin
                            Validate("Ship Action", "Ship Action"::Fullfill);
                            Validate("Qty. Avail.", QtyAvailable);
                            //VALIDATE("Qty. To Ship","Qty. Reqd." - ("Qty. On Pick" + "Picked Qty."));
                            if QtyAvailable >= ("Qty. Reqd." - ("Picked Qty." + "Qty. On Pick")) then begin
                                "Short By Qty." := 0;
                                "Back Order Qty." := 0;
                            end;
                            Select := true;
                            "Locked By User ID" := UserId;
                            Modify;
                        end else begin
                            Validate("Ship Action", "Ship Action"::"Back Order");
                            Validate("Qty. Avail.", QtyAvailable);
                            //VALIDATE("Qty. To Ship",QtyAvailable);
                            "Short By Qty." := QtyAvailable - ("Qty. Reqd." - ("Qty. On Pick" + "Picked Qty."));
                            "Back Order Qty." := "Qty. Reqd." - ("Qty. On Pick" + "Picked Qty." + "Qty. To Ship");  //EN1.07
                            Select := true;
                            "Locked By User ID" := UserId;
                            Modify;
                        end
                    end else begin
                        Validate("Qty. Avail.", 0);
                        "Qty. To Ship" := 0;
                        "Short By Qty." := 0;
                        "Back Order Qty." := 0;
                        Validate("Ship Action", "Ship Action"::" ");
                        "Locked By User ID" := '';
                        Modify;
                    end;
                end;
            end;
        }
        field(10; ID; Integer)
        {
            AutoIncrement = true;
        }
        field(20; Level; Integer)
        {
        }
        field(21; "Parent ID"; Integer)
        {
        }
        field(29; "Ship-to Code"; Code[20])
        {
        }
        field(30; "Ship-to Name"; Text[50])
        {
        }
        field(31; "Ship-to Address"; Text[50])
        {
        }
        field(32; "Ship-to Address 2"; Text[50])
        {
        }
        field(33; "Ship-to City"; Text[30])
        {
        }
        field(34; "Ship-to State"; Text[30])
        {
        }
        field(35; "Ship-to Zip Code"; Text[20])
        {
        }
        field(36; "Ship-to Country"; Code[10])
        {
        }
        field(37; "Ship-to Contact"; Text[50])
        {
        }

        field(50; "Shipment No."; Code[20])
        {
        }
        field(51; "Shipment Line No."; Integer)
        {
        }
        field(52; "Source No."; Code[20])
        {
        }
        field(53; "Source Line No."; Integer)
        {
        }
        field(54; "Source Type"; Integer)
        {
        }
        field(55; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(56; "Source Document"; Option)
        {
            Caption = 'Source Document';
            Editable = false;
            OptionCaption = ',Sales Order,,,Sales Return Order,Purchase Order,,,Purchase Return Order,,Outbound Transfer';
            OptionMembers = ,"Sales Order",,,"Sales Return Order","Purchase Order",,,"Purchase Return Order",,"Outbound Transfer";
        }
        field(60; "External Doc. No."; Code[20])
        {

        }
        field(61; "Trip No."; Code[20])
        {
            TableRelation = "Trip Load Order ELA" where("Source Document Type" = filter("Sales Order" | "Transfer Order"));
        }

        field(62; "Driver No."; Code[20])
        {
            TableRelation = "Delivery Driver ELA";
            DataClassification = ToBeClassified;
        }

        field(63; "Truck Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Shipment Date"; Date)
        {
        }
        field(81; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
            trigger OnValidate()
            var
                lCust: Record Customer;
            begin
            end;
        }

        // field(82; "MyField"; Blob)
        // {
        //     DataClassification = ToBeClassified;
        // }

        // field(90; Status; Option)
        // {
        //     OptionCaption = 'Open,Released';
        //     OptionMembers = Open,Released;

        //     trigger OnValidate()
        //     var
        //         ShipDashBrd: Record "EN Shipment Dashboard";
        //     begin
        //         ShipDashBrd.Reset;
        //         ShipDashBrd.SetRange("Parent ID", ID);
        //         ShipDashBrd.SetRange(Level, 1);
        //         ShipDashBrd.ModifyAll(Status, Status);
        //     end;
        // }
        field(100; "Full Pick"; Boolean)
        {

            // trigger OnValidate()
            // var
            //     ShipDashBrd: Record "EN Shipment Dashboard";
            //     ShipDashBrd2: Record "EN Shipment Dashboard";
            // begin
            // end;
        }
        field(110; "Partial Pick"; Boolean)
        {
        }
        field(1010; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(1020; "Item Description"; Text[50])
        {
        }
        field(1030; "Unit of Measure Code"; Text[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(1040; "Qty. Reqd."; Decimal)
        {
        }
        field(1041; "Orig. Ordered Qty."; Decimal)
        {
        }
        field(1042; "Last Modified Qty."; Decimal)
        {
        }
        field(1050; "Qty. Avail."; Decimal)
        {

            trigger OnValidate()
            var
                NetReqdQty: Decimal;
            begin
                CalcFields("Qty. On Pick");
                NetReqdQty := "Qty. Reqd." - ("Picked Qty." + "Qty. On Pick");
                if NetReqdQty > 0 then begin
                    if NetReqdQty > "Qty. Avail." then
                        Validate("Qty. To Ship", "Qty. Avail.")
                    else
                        Validate("Qty. To Ship", NetReqdQty);
                end;
            end;
        }
        field(1060; "Qty. To Ship"; Decimal)
        {

            trigger OnValidate()
            var
                WhseShipLine: Record "Warehouse Shipment Line";
            begin
                "C/OS" := ("Qty. To Ship" + "Picked Qty." + "Qty. On Pick") - "Orig. Ordered Qty.";
                CalcFields("Qty. On Pick");
                if ("Qty. To Ship" < 0) then begin
                    "Qty. To Ship" := xRec."Qty. To Ship";
                    exit;
                end;

                if ("Qty. To Ship" + "Picked Qty." + "Qty. On Pick" > "Qty. Reqd.") then begin // overship
                    if not Confirm(
                      StrSubstNo(
                        TEXT14229220, "Item No.", ("Qty. To Ship" + "Picked Qty." + "Qty. On Pick") - "Qty. Reqd.", "Unit of Measure Code",
                        "Qty. To Ship" + "Picked Qty." + "Qty. On Pick", "Unit of Measure Code", "Source No."))
                    then begin
                        "Qty. To Ship" := xRec."Qty. To Ship";
                        "Cut/Overship" := xRec."Cut/Overship";
                        "Last Modified Qty." := xRec."Qty. Reqd.";
                        exit;
                    end else begin
                        "Cut/Overship" := "C/OS";
                        "Last Modified Qty." := xRec."Qty. Reqd.";
                        ShipDBMgt.AdjustShipQtyToOrderLine(Rec, "Shipment No.", "Shipment Line No.", "Qty. To Ship" + "Picked Qty." + "Qty. On Pick");
                        "Qty. Reqd." := "Qty. To Ship" + "Picked Qty." + "Qty. On Pick";
                        "Qty. To Ship" := "Qty. Reqd." - ("Picked Qty." + "Qty. On Pick");
                        if ("Qty. To Ship" > "Qty. Avail.") then
                            "Qty. To Ship" := "Qty. Avail.";

                        if "Qty. Avail." - ("Qty. Reqd." - ("Qty. On Pick" + "Picked Qty.")) < 0 then
                            "Short By Qty." := "Qty. Avail." - ("Qty. Reqd." - ("Qty. On Pick" + "Picked Qty."))
                        else
                            "Short By Qty." := 0;

                        if "Full Pick" and ("Qty. Reqd." - ("Qty. On Pick" + "Picked Qty." + "Qty. To Ship") <> 0) then begin
                            "Full Pick" := false;
                            "Partial Pick" := true;
                        end;

                        "Back Order Qty." := "Qty. Reqd." - ("Qty. On Pick" + "Picked Qty." + "Qty. To Ship");
                        if ("Orig. Ordered Qty." <> 0) and ("Qty. To Ship" >= "Orig. Ordered Qty.") then
                            Validate("Ship Action", "Ship Action"::"Over Ship");
                    end;
                end else
                    if ("Qty. To Ship" - ("Picked Qty." + "Qty. On Pick") >= 0) and
              ("Qty. To Ship" - ("Picked Qty." + "Qty. On Pick") < "Qty. Reqd.") then begin //back order/fullfill
                        if ("Qty. To Ship" > "Qty. Avail.") then
                            "Qty. To Ship" := "Qty. Avail.";

                        if "Qty. Avail." - ("Qty. Reqd." - ("Qty. On Pick" + "Picked Qty.")) < 0 then
                            "Short By Qty." := "Qty. Avail." - ("Qty. Reqd." - ("Qty. On Pick" + "Picked Qty."))
                        else
                            "Short By Qty." := 0;

                        "Back Order Qty." := "Qty. Reqd." - ("Qty. On Pick" + "Picked Qty." + "Qty. To Ship");
                        Validate("Ship Action", "Ship Action"::"Back Order");
                    end else
                        if "Qty. Reqd." = "Qty. To Ship" + "Qty. On Pick" + "Picked Qty." then
                            Validate("Ship Action", "Ship Action"::Fullfill);

                if "Qty. To Ship" > 0 then
                    "Has Qty. Allocated" := true;

                if "Orig. Ordered Qty." = 0 then
                    "Orig. Ordered Qty." := "Qty. Reqd.";

                "Back Order Qty." := "Qty. Reqd." - ("Qty. To Ship" + "Picked Qty." + "Qty. On Pick");
                if "Qty. Reqd." = "Picked Qty." then begin
                    "Back Order Qty." := 0;
                    "Short By Qty." := 0;
                    Validate(Completed, true);
                end else
                    if "Qty. Reqd." > "Qty. To Ship" + "Picked Qty." + "Qty. On Pick" then begin
                        Validate(Completed, false);
                    end else
                        Validate(Completed, false);

                if WhseShipLine.Get("Shipment No.", "Shipment Line No.") then begin
                    if "Qty. To Ship" <= 0 then begin
                        WhseShipLine."Qty. to Handle ELA" := 0;
                        WhseShipLine."Qty. to Handle (Base) ELA" := 0;
                    end else begin
                        WhseShipLine."Qty. to Handle ELA" := "Qty. To Ship";
                        WhseShipLine."Qty. to Handle (Base) ELA" := "Qty. To Ship" * WhseShipLine."Qty. per Unit of Measure";
                    end;
                    WhseShipLine.Modify;
                end;
            end;
        }
        field(1070; "Has Qty. Allocated"; Boolean)
        {
        }
        field(1071; "Qty. Allocated"; Decimal)
        {
        }
        field(1080; "Picked Qty."; Decimal)
        {
        }
        field(1081; "Back Order Qty."; Decimal)
        {
        }
        field(1082; "Qty. On Pick"; Decimal)
        {
            CalcFormula = Sum("Warehouse Activity Line"."Qty. Outstanding" WHERE("Activity Type" = CONST(Pick),
                                                                                  "Whse. Document Type" = CONST(Shipment),
                                                                                  "Whse. Document No." = FIELD("Shipment No."),
                                                                                  "Whse. Document Line No." = FIELD("Shipment Line No."),
                                                                                  "Unit of Measure Code" = FIELD("Unit of Measure Code"),
                                                                                  "Action Type" = FILTER(" " | Place),
                                                                                  "Original Breakbulk" = CONST(false),
                                                                                  "Breakbulk No." = CONST(0)));
            DecimalPlaces = 2 : 0;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1090; "Short By Qty."; Decimal)
        {
        }
        field(1100; "Ship Action"; Enum "WMS Ship Acion ELA")
        {
            // OptionCaption = ' ,Fullfill,Cut,Over Ship,Back Order';
            // OptionMembers = " ",Fullfill,Cut,"Over Ship","Back Order";
            trigger OnValidate()
            begin
                ApplyShipAction(true);
            end;


        }
        field(1110; "Assigned App. Role"; Code[20])
        {
            TableRelation = "App. Role ELA";

            trigger OnValidate()
            var
                ShipDashBrd: Record "Shipment Dashboard ELA";
                WsheShipHdr: Record "Warehouse Shipment Header";
                WsheShipLine: Record "Warehouse Shipment Line";
            begin
                if Level = 0 then begin
                    ShipDashBrd.Reset;
                    ShipDashBrd.SetRange("Parent ID", ID);
                    ShipDashBrd.SetRange(Level, 1);
                    ShipDashBrd.SetRange(Completed, false);
                    if ShipDashBrd.FindSet then
                        repeat
                            ShipDashBrd."Assigned App. Role" := "Assigned App. Role";
                            ShipDashBrd.Modify;

                            ShipDBMgt.UpdateRoleAssignment("Source No.", 0, 0, 0, 0,
                              "Assigned App. Role", true, UpdateSource::ShipBoard, ActivityType::" ");
                        until ShipDashBrd.Next = 0;
                end else
                    if (Level = 1) and not Completed then
                        ShipDBMgt.UpdateRoleAssignment("Source No.", "Source Line No.", 0, "Source Type", "Source Subtype",
                          "Assigned App. Role", false, UpdateSource::ShipBoard, ActivityType::" ");
            end;
        }
        field(1120; Completed; Boolean)
        {

            trigger OnValidate()
            var
                ShipmentDshbrd: Record "Shipment Dashboard ELA";
            begin
                if Level <> 0 then begin
                    ShipmentDshbrd.Reset;
                    ShipmentDshbrd.SetRange("Parent ID", "Parent ID");
                    ShipmentDshbrd.SetRange(Completed, false);
                    if ShipmentDshbrd.Count = 0 then begin
                        ShipmentDshbrd.Reset;
                        ShipmentDshbrd.Get("Parent ID");
                        ShipmentDshbrd.Completed := true;
                    end;
                end;

                // if Completed then
                //     ShipDBMgt.CreateBillOfLading("Source No.", "Shipment No.", '');
            end;
        }
        field(1130; "BOL Registered"; Boolean)
        {
        }
        field(1140; Location; Code[20])
        {
        }
        field(1150; "Last Updated"; DateTime)
        {
        }
        field(1160; "Locked By User ID"; Code[20])
        {
        }
        field(1170; "Released Timestamp"; DateTime)
        {
        }
        field(1180; "Receive To Pick"; Boolean)
        {
        }
        field(1200; "Assigned App. User"; Code[20])
        {
            Caption = 'Assigned Picker';
            TableRelation = "Application User ELA"."User ID";
            trigger OnValidate()
            var
                ShipDashBrd: Record "Shipment Dashboard ELA";
                WsheShipHdr: Record "Warehouse Shipment Header";
                WsheShipLine: Record "Warehouse Shipment Line";
            begin
                if Level = 0 then begin
                    ShipDashBrd.Reset;
                    ShipDashBrd.SetRange("Parent ID", ID);
                    ShipDashBrd.SetRange(Level, 1);
                    ShipDashBrd.SetRange(Completed, false);
                    if ShipDashBrd.FindSet then
                        repeat
                            ShipDashBrd."Assigned App. User" := "Assigned App. User";
                            ShipDashBrd.Modify;
                            ShipDBMgt.UpdateUserAssignment(ShipDashBrd."Source No.", 0, 0, 0, 0,
                              "Assigned App. User", true, UpdateSource::ShipBoard, ActivityType::" ");
                        until ShipDashBrd.Next = 0;
                end else
                    if Level = 1 then
                        if not Completed then
                            ShipDBMgt.UpdateUserAssignment("Source No.", "Source Line No.", 0, "Source Type", "Source Subtype",
                              "Assigned App. User", false, UpdateSource::ShipBoard, ActivityType::" ");
            end;
        }
        // field(1210; "Packing Unit"; Option)
        // {
        //     Description = 'EN1.10';
        //     OptionCaption = ' ,Cases,Trays,Lbs';
        //     OptionMembers = " ",Cases,Trays,Lbs;

        //     trigger OnValidate()
        //     var
        //         ShipDashBrd: Record "EN Shipment Dashboard";
        //     begin
        //         //<<EN1.10
        //         if Level = 0 then begin
        //             ShipDashBrd.Reset;
        //             ShipDashBrd.SetRange("Parent ID", ID);
        //             ShipDashBrd.SetRange(Level, 1);
        //             ShipDashBrd.SetRange(Completed, false);
        //             if ShipDashBrd.FindSet then
        //                 repeat
        //                     ShipDashBrd."Packing Unit" := "Packing Unit";
        //                     ShipDashBrd.Modify;
        //                     ShipDBMgt.UpdatePackingUnit(ShipDashBrd."Source No.", 0, 0, 0, 0,
        //                       "Packing Unit", true, UpdateSource::ShipBoard, ActivityType::" ");
        //                 until ShipDashBrd.Next = 0;
        //         end else
        //             if Level = 1 then
        //                 if not Completed then
        //                     ShipDBMgt.UpdatePackingUnit("Source No.", "Source Line No.", 0, "Source Type", "Source Subtype",
        //                       "Packing Unit", false, UpdateSource::ShipBoard, ActivityType::" ");
        //         //>>EN1.10
        //     end;
        // }
        field(14229220; "Cut/Overship"; Decimal)
        {
            trigger OnValidate()
            var
                register: Codeunit 7307;
            begin
                ShipDBMgt.AdjustShipQtyToOrderLine(Rec, "Shipment No.", "Shipment Line No.", "Qty. To Ship" + "Picked Qty." + "Qty. On Pick");
            end;
        }
        field(14229221; "Ship-from Code"; Code[20])
        {
        }
        field(14229222; "Ship-from Name"; Text[50])
        {
        }
        field(14229223; "Ship-from Address"; Text[50])
        {
        }
        field(14229224; "Ship-from Address 2"; Text[50])
        {
        }
        field(14229225; "Ship-from City"; Text[30])
        {
        }
        field(14229226; "Ship-from State"; Text[30])
        {
        }

        field(14229227; "Ship-from Zip Code"; Text[20])
        {
        }
        field(14229228; "Ship-from Country"; Code[10])
        {
        }
        field(14229229; "Ship-from Contact"; Text[50])
        {
        }
        field(14229230; "Destination No."; Code[20])
        {
            // CalcFormula = Lookup("Sales Header"."Sell-to Customer No." WHERE("No." = FIELD("Source No.")));
            // FieldClass = FlowField;
        }
        // field(14229230; Type; Option)
        // {
        //     OptionCaption = ' ,Raw Material,Packaging,Intermediate,Finished Good,Container,Spare';
        //     OptionMembers = " ","Raw Material",Packaging,Intermediate,"Finished Good",Container,Spare;
        // }
        field(14229232; "Picked By User ID"; Code[10])
        {
        }
        field(14229233; "Picked Date Time"; DateTime)
        {
        }
        field(14229239; "Release to QC"; Boolean)
        {
            DataClassification = ToBeClassified;
            /*trigger OnValidate()
            var
                shipmentMgmt: codeunit "Shipment Mgmt. ELA";
            begin
                TestField("Picked Qty.");
                shipmentMgmt.UpdateShipmentLineDashReleaseQC(rec);
            end;*/
        }
        field(14229240; "QC Completed"; Boolean)
        {
            DataClassification = ToBeClassified;
            /*trigger OnValidate()
             var
                 shipmentMgmt: codeunit "Shipment Mgmt. ELA";
             begin
                 TestField("Release to QC", true);
                 shipmentMgmt.UpdateShipmentLineDashQCComplete(rec);
             end;*/
        }

        field(14229241; "Assigned QC User"; Code[20])
        {
            Caption = 'Assigned QC User';
            TableRelation = "Application User ELA"."User ID";
            DataClassification = ToBeClassified;
            /*trigger OnValidate()
            var
                shipmentMgmt: codeunit "Shipment Mgmt. ELA";
            begin
                //TestField("Release to QC", true);
                shipmentMgmt.UpdateShipmentLineDashAssignedToQC(rec);
            end;*/
        }
        // field(14229234; "Order Type"; Option)
        // {
        //     OptionCaption = ' ,Raw Material';
        //     OptionMembers = " ","Raw Material";
        // }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
        key(Key2; "Parent ID")
        {
        }
        key(Key3; "Item No.")
        {
        }
        key(Key4; "Shipment Date")
        {
        }
        key(Key5; "Shipment Date", "Ship-to Name")
        {
        }
        key(Key6; "Shipment Date", "Source No.", "Ship-to Name")
        {
        }
        key(Key7; "Shipment No.", "Shipment Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
    begin
    end;

    trigger OnInsert()
    begin
        "Last Updated" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Updated" := CurrentDateTime;
    end;

    var
        TEXT14229220: Label 'Do you want to Overship the item %1 for additional %2 %3.\nTotal Qty would be on %4 %5 on Order %6?';
        ShipDBMgt: Codeunit "Shipment Mgmt. ELA";
        TEXT14229221: Label 'Do you want to Cut the qty to %1 from Qty %2 for item %3 on the order %4? ';
        // PLRegMgt: Codeunit "Prod. Load Reg. Mgmt.";
        TEXT14229222: Label 'Shipment No. %1 Item %2 is already released for picking';
        UpdateSource: Option " ",Shipment,"Task Queue",Activity,ShipBoard;
        ActivityType: Option " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick";
        TEXT14229223: Label 'Order No. %1 is locked by User %2? Do you want to clear the lock?';
        TEXT14229224: Label 'Order No. %1 Item No. %2 is locked by User %3? Do you want to clear the lock?';
        TEXT14229225: Label 'You have already selected Order No. %1. Do you want to de-select the Order No. %2?';
        TEXT50006: Label 'Qty. To Ship %1 cannot be less than Picked Qty %2 for Item No. %3. ';
        TEXT14229227: Label 'You cannot cut the Qty. %1 on Item No. %2 less than Picked Qty %3.';
        HideDialogBox: Boolean;
        TEXT14229228: Label 'Item No. %1  : Cut/Overship : %2 Case : New Total : %3';
        TEXT14229229: Label 'Do you want to add  %1 in Cut/Overship report ?';
        BoxOvership: Decimal;
        "C/OS": Decimal;
        SalesLine: Record "Sales Line";
        TransferHeader: Record "Transfer Header";
        Item: Record Item;

    procedure GetQuantityAvailable(ShipDashbrd: Record "Shipment Dashboard ELA"): Decimal
    var
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        ShipDashbrd2: Record "Shipment Dashboard ELA";
        QtyAllocated: Decimal;
        ILEQty: Decimal;
    begin
        ItemLedgEntry.Reset;
        ItemLedgEntry.SetRange("Item No.", ShipDashbrd."Item No.");
        ItemLedgEntry.SetRange("Drop Shipment", false);
        ItemLedgEntry.SetRange("Location Code", ShipDashbrd.Location);
        if ItemLedgEntry.FindSet then
            repeat
                ILEQty := ILEQty + ItemLedgEntry."Remaining Quantity";
            until ItemLedgEntry.Next = 0;

        exit(ILEQty);
    end;

    procedure GetAllocatedQty(ShipDashbrd: Record "Shipment Dashboard ELA"): Decimal
    var
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        ShipDashbrd2: Record "Shipment Dashboard ELA";
        QtyAllocated: Decimal;
        ILEQty: Decimal;
    begin
    end;

    procedure UpdateRemainingQty(AllocatedQty: Decimal)
    var
        ShipDashbrd2: Record "Shipment Dashboard ELA";
        ItemLedgEntry: Record "Item Ledger Entry";
        ILEQty: Decimal;
        QtyAllocated: Decimal;
    begin
    end;

    procedure UpdateAllShipStockInfo()
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
    begin
        ShipDashBrd.Reset;
        ShipDashBrd.SetRange(Completed, false);
        if ShipDashBrd.FindSet then
            repeat
                UpdateShipStockInfo(ShipDashBrd);
            until ShipDashBrd.Next = 0;
    end;

    procedure UpdateShipStockInfo(ShipDashbrd: Record "Shipment Dashboard ELA")
    var
        AvailableQty: Decimal;
    begin
    end;

    procedure DeSelectOrder(TripNo: code[20]; OrderNo: Code[20]; UseTrip: Boolean)
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
    begin
        ShipDashBrd.Reset;
        if (UseTrip) then
            ShipDashBrd.SetRange("Trip No.", TripNo)
        else
            ShipDashBrd.SetRange("Source No.", OrderNo);

        ShipDashBrd.SetRange("Locked By User ID", UserId);
        if ShipDashBrd.FindSet then
            repeat
                ShipDashBrd.CalcFields("Qty. On Pick");
                ShipDashBrd."Qty. Avail." := 0;
                ShipDashBrd."Qty. To Ship" := 0;
                ShipDashBrd."Locked By User ID" := '';
                ShipDashBrd."Ship Action" := ShipDashBrd."Ship Action"::" ";
                ShipDashBrd.Select := false;
                ShipDashBrd.Modify;
            until ShipDashBrd.Next = 0;
    end;

    procedure ApplyShipAction(ShowDialog: Boolean)
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
        WhseShipHdr: Record "Warehouse Shipment Header";
        WhseShipLine: Record "Warehouse Shipment Line";
        SalesLine: Record "Sales Line";
        ApplyAction: Boolean;
    begin
        CalcFields("Qty. On Pick");
        if "Ship Action" = "Ship Action"::Cut then begin
            if "Qty. Reqd." < ("Back Order Qty." + "Picked Qty." + "Qty. On Pick") then
                Error(StrSubstNo(TEXT14229227, "Qty. To Ship", "Item No.", "Picked Qty."));
            if ShowDialog then
                ApplyAction := Confirm(StrSubstNo(TEXT14229221, "Picked Qty." + "Qty. On Pick" + "Qty. To Ship", "Qty. Reqd.", "Item No.", "Source No."), false)
            else
                ApplyAction := true;
            if ApplyAction then begin
                "C/OS" := ("Qty. To Ship" + "Picked Qty." + "Qty. On Pick") - "Orig. Ordered Qty.";
                "Cut/Overship" := "C/OS";
                ShipDBMgt.AdjustShipQtyToOrderLine(Rec, "Shipment No.", "Shipment Line No.",
                  "Picked Qty." + "Qty. On Pick" + "Qty. To Ship");
                //"Qty. Reqd." - "Back Order Qty.");
                "Qty. Reqd." := "Picked Qty." + "Qty. On Pick" + "Qty. To Ship";
                "Back Order Qty." := 0;
                Validate("Qty. To Ship", "Qty. Reqd." - ("Picked Qty." + "Qty. On Pick"));
                if "Qty. Reqd." = "Qty. To Ship" + "Picked Qty." + "Qty. On Pick" then
                    "Full Pick" := true;
                "Ship Action" := "Ship Action"::Cut;
            end else begin
                "Qty. Reqd." := xRec."Qty. Reqd.";
                "Qty. To Ship" := xRec."Qty. To Ship";
                "Ship Action" := xRec."Ship Action";
            end;
            "Ship Action" := "Ship Action"::" ";
        end;

        if "Ship Action" = "Ship Action"::Fullfill then begin
            "Back Order Qty." := 0;
            "Short By Qty." := 0;
        end;

        if SalesLine.Get(SalesLine."Document Type"::Order, "Source No.", "Source Line No.") then begin
            if SalesLine."Ship Action ELA" <> Rec."Ship Action" then begin
                SalesLine."Ship Action ELA" := Rec."Ship Action";
                SalesLine.Modify;
            end;

            if WhseShipLine.Get("Shipment No.", "Shipment Line No.") then begin
                WhseShipLine."Ship Action ELA" := "Ship Action";
                WhseShipLine.Modify;
            end;
        end;
    end;
}

