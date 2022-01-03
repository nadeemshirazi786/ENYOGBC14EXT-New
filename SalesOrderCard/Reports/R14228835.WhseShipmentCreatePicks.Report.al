report 23019780 "Whse.-Ship - Create Picks ELA"
{
    Caption = 'Whse.-Shipment - Create Picks';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
        {
            DataItemTableView = SORTING ("No.", "Line No.");
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                CurrReport.Skip;
            end;

            trigger OnPostDataItem()
            var
                TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
                ItemTrackingMgt: Codeunit "Item Tracking Management";
            begin
            end;

            trigger OnPreDataItem()
            begin
                SetFilter(Quantity, '>0');
                WhseShptLine.CopyFilters("Warehouse Shipment Line");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group("Create Pick")
                    {
                        Caption = 'Create Pick';
                        field(gblnPerLineNo; gblnPerLineNo)
                        {
                            Caption = 'Per Line No.';
                        }
                        field(gblnPerSourceNo; gblnPerSourceNo)
                        {
                            Caption = 'Per Source No.';
                        }
                        field(gblnPerDest; gblnPerDest)
                        {
                            Caption = 'Per Cust./Vend./Loc.';
                        }
                        field(gblnPerItem; gblnPerItem)
                        {
                            Caption = 'Per Item';
                        }
                        field(gblnPerDefaultPickBin; gblnPerDefaultPickBin)
                        {
                            Caption = 'Per Default Pick Bin';
                        }
                    }
                    field(AssignedID; AssignedID)
                    {
                        Caption = 'Assigned User ID';
                        TableRelation = "Warehouse Employee";

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            WhseEmployee: Record "Warehouse Employee";
                            LookupWhseEmployee: Page "Warehouse Employee List";
                        begin
                            WhseEmployee.SetCurrentKey("Location Code");
                            WhseEmployee.SetRange("Location Code", Location.Code);
                            LookupWhseEmployee.LookupMode(true);
                            LookupWhseEmployee.SetTableView(WhseEmployee);
                            if LookupWhseEmployee.RunModal = ACTION::LookupOK then begin
                                LookupWhseEmployee.GetRecord(WhseEmployee);
                                AssignedID := WhseEmployee."User ID";
                            end;
                        end;

                        trigger OnValidate()
                        var
                            WhseEmployee: Record "Warehouse Employee";
                        begin
                            if AssignedID <> '' then
                                WhseEmployee.Get(AssignedID, Location.Code);
                        end;
                    }
                    field(SortActivity; SortActivity)
                    {
                        Caption = 'Sorting Method for Activity Lines';
                        MultiLine = true;
                        OptionCaption = ' ,Item,Document,Shelf or Bin,Due Date,Destination,Bin Ranking,Action Type';
                    }
                    field(BreakbulkFilter; BreakbulkFilter)
                    {
                        Caption = 'Set Breakbulk Filter';
                    }
                    field(DoNotFillQtytoHandle; DoNotFillQtytoHandle)
                    {
                        Caption = 'Do Not Fill Qty. to Handle';
                    }
                    field(PrintDoc; PrintDoc)
                    {
                        Caption = 'Print Document';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if Location."Use ADCS" then
                DoNotFillQtytoHandle := true;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        WhseActivHeader: Record "Warehouse Activity Header";
        TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        lintPick: Integer;
    begin
        if gblnPerLineNo then begin
            WhseShptLine.SetRange("No.", WhseShptHeader."No.");
            WhseShptLine.SetFilter(Quantity, '>0');
            WhseShptLine.SetRange("Completely Picked", false);
            if WhseShptLine.FindSet then begin
                gdlgWindow.Open(Text012);
                repeat
                    lintPick := lintPick + 1;
                    gdlgWindow.Update(1, lintPick);
                    Clear(CreatePickFromWhseShpt);
                    grecWhseShptLine.SetRange("No.", WhseShptHeader."No.");
                    grecWhseShptLine.SetRange("Line No.", WhseShptLine."Line No.");
                    CreatePickFromWhseShpt.SetWhseShipmentLine(grecWhseShptLine, WhseShptHeader);
                    CreatePickFromWhseShpt.Initialize(AssignedID, SortActivity, PrintDoc, DoNotFillQtytoHandle, BreakbulkFilter);//
                    CreatePickFromWhseShpt.SetHideValidationDialog(true);
                    CreatePickFromWhseShpt.UseRequestPage(false);
                    CreatePickFromWhseShpt.SetTableView(grecWhseShptLine);
                    CreatePickFromWhseShpt.RunModal;
                    //<JF17561SHR>
                    Commit;
                    //</JF17561SHR>
                until WhseShptLine.Next = 0;
                gdlgWindow.Close;
                CreatePickFromWhseShpt.GetResultMessage;
                Clear(CreatePickFromWhseShpt);
                exit;
            end else begin
                if not HideValidationDialog then begin
                    Message(Text011);
                end;
            end;
        end else begin
            if gblnPerSourceNo then begin
                WhseShptLine.SetRange("No.", WhseShptHeader."No.");
                WhseShptLine.SetFilter(Quantity, '>0');
                WhseShptLine.SetRange("Completely Picked", false);
                if WhseShptLine.FindSet then begin
                    repeat
                        grecBufferTemp.Key1 := WhseShptLine."Source No.";
                        if gblnPerItem then begin
                            grecBufferTemp.Key2 := WhseShptLine."Item No.";
                            if gblnPerDefaultPickBin then begin
                                //grecBufferTemp.Key3 := WhseShptLine."Def. Pick Bin";
                            end;
                        end else begin
                            if gblnPerDefaultPickBin then begin
                                //grecBufferTemp.Key2 := WhseShptLine."Def. Pick Bin";
                            end;
                        end;
                        if not grecBufferTemp.INSERT then;
                    until WhseShptLine.Next = 0;
                end;
            end else begin
                if gblnPerDest then begin
                    WhseShptLine.SetRange("No.", WhseShptHeader."No.");
                    WhseShptLine.SetFilter(Quantity, '>0');
                    WhseShptLine.SetRange("Completely Picked", false);
                    if WhseShptLine.FindSet then begin
                        repeat
                            grecBufferTemp.Key1 := Format(WhseShptLine."Destination Type");
                            grecBufferTemp.Key2 := WhseShptLine."Destination No.";
                            grecBufferTemp.Integer1 := WhseShptLine."Destination Type";
                            if gblnPerItem then begin
                                grecBufferTemp.Key3 := WhseShptLine."Item No.";
                                if gblnPerDefaultPickBin then begin
                                    //grecBufferTemp.Key4 := WhseShptLine."Def. Pick Bin";
                                end;
                            end else begin
                                if gblnPerDefaultPickBin then begin
                                    //grecBufferTemp.Key3 := WhseShptLine."Def. Pick Bin";
                                end;
                            end;
                            if not grecBufferTemp.INSERT then;
                        until WhseShptLine.Next = 0;
                    end;
                end else begin
                    if gblnPerItem then begin
                        WhseShptLine.SetRange("No.", WhseShptHeader."No.");
                        WhseShptLine.SetFilter(Quantity, '>0');
                        WhseShptLine.SetRange("Completely Picked", false);
                        if WhseShptLine.Find('-') then begin
                            repeat
                                grecBufferTemp.Key1 := WhseShptLine."Item No.";
                                if gblnPerDefaultPickBin then begin
                                    //grecBufferTemp.Key2 := WhseShptLine."Def. Pick Bin";
                                end;
                                if not grecBufferTemp.INSERT then;
                            until WhseShptLine.Next = 0;
                        end;
                    end else begin
                        if gblnPerDefaultPickBin then begin
                            WhseShptLine.SetRange("No.", WhseShptHeader."No.");
                            WhseShptLine.SetFilter(Quantity, '>0');
                            WhseShptLine.SetRange("Completely Picked", false);
                            if WhseShptLine.Find('-') then begin
                                repeat
                                    //grecBufferTemp.Key1 := WhseShptLine."Def. Pick Bin";
                                    if not grecBufferTemp.INSERT then;
                                until WhseShptLine.Next = 0;
                            end;
                        end else begin
                            WhseShptLine.SetRange("No.", WhseShptHeader."No.");
                            WhseShptLine.SetFilter(Quantity, '>0');
                            WhseShptLine.SetRange("Completely Picked", false);

                            if WhseShptLine.Find('-') then begin
                                gdlgWindow.Open(Text012);
                                lintPick := lintPick + 1;
                                gdlgWindow.Update(1, lintPick);
                                Clear(CreatePickFromWhseShpt);
                                grecWhseShptLine.SetRange("No.", WhseShptHeader."No.");
                                CreatePickFromWhseShpt.SetWhseShipmentLine(grecWhseShptLine, WhseShptHeader);
                                CreatePickFromWhseShpt.Initialize(AssignedID, SortActivity, PrintDoc, DoNotFillQtytoHandle, BreakbulkFilter);
                                CreatePickFromWhseShpt.SetHideValidationDialog(true);
                                CreatePickFromWhseShpt.UseRequestPage(false);
                                CreatePickFromWhseShpt.SetTableView(grecWhseShptLine);
                                CreatePickFromWhseShpt.RunModal;
                                CreatePickFromWhseShpt.GetResultMessage;
                                Clear(CreatePickFromWhseShpt);
                                gdlgWindow.Close;
                                //<JF17561SHR>
                                Commit;
                                //</JF17561SHR>
                                exit;
                            end else begin
                                if not HideValidationDialog then begin
                                    Message(Text011);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;

        grecBufferTemp.RESET;
        if grecBufferTemp.FINDSET then begin
            gdlgWindow.Open(Text012);
            repeat
                lintPick := lintPick + 1;
                gdlgWindow.Update(1, lintPick);

                Clear(CreatePickFromWhseShpt);
                grecWhseShptLine.SetRange("No.", WhseShptHeader."No.");
                if gblnPerSourceNo then begin
                    grecWhseShptLine.SetRange("Source No.", grecBufferTemp.Key1);
                    if gblnPerItem then begin
                        grecWhseShptLine.SetRange("Item No.", grecBufferTemp.Key2);
                        if gblnPerDefaultPickBin then begin
                            //grecWhseShptLine.SetRange("Def. Pick Bin", grecBufferTemp.Key3);
                        end;
                    end else begin
                        if gblnPerDefaultPickBin then begin
                            //grecWhseShptLine.SetRange("Def. Pick Bin", grecBufferTemp.Key2);
                        end;
                    end;
                end else begin
                    if gblnPerDest then begin
                        grecWhseShptLine.SetRange("Destination Type", grecBufferTemp.Integer1);
                        grecWhseShptLine.SetRange("Destination No.", grecBufferTemp.Key2);
                        if gblnPerItem then begin
                            grecWhseShptLine.SetRange("Item No.", grecBufferTemp.Key3);
                            if gblnPerDefaultPickBin then begin
                                //grecWhseShptLine.SetRange("Def. Pick Bin", grecBufferTemp.Key4);
                            end;
                        end else begin
                            if gblnPerDefaultPickBin then begin
                                //grecWhseShptLine.SetRange("Def. Pick Bin", grecBufferTemp.Key3);
                            end;
                        end;
                    end else begin
                        if gblnPerItem then begin
                            grecWhseShptLine.SetRange("Item No.", grecBufferTemp.Key1);
                            if gblnPerDefaultPickBin then begin
                                //grecWhseShptLine.SetRange("Def. Pick Bin", grecBufferTemp.Key2);
                            end;
                        end else begin
                            if gblnPerDefaultPickBin then begin
                                //grecWhseShptLine.SetRange("Def. Pick Bin", grecBufferTemp.Key1);
                            end;
                        end;
                    end;
                end;


                CreatePickFromWhseShpt.SetWhseShipmentLine(grecWhseShptLine, WhseShptHeader);
                CreatePickFromWhseShpt.Initialize(AssignedID, SortActivity, PrintDoc, DoNotFillQtytoHandle, BreakbulkFilter);//
                CreatePickFromWhseShpt.SetHideValidationDialog(true);
                CreatePickFromWhseShpt.UseRequestPage(false);
                CreatePickFromWhseShpt.SetTableView(grecWhseShptLine);
                CreatePickFromWhseShpt.RunModal;
                //<JF17561SHR>
                Commit;
                //</JF17561SHR>
            until grecBufferTemp.NEXT = 0;
            CreatePickFromWhseShpt.GetResultMessage;
            Clear(CreatePickFromWhseShpt);
            gdlgWindow.Close;
            exit;
        end else begin
            if not HideValidationDialog then begin
                Message(Text011);
            end;
        end;
    end;

    var
        Location: Record Location;
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseWkshLine: Record "Whse. Worksheet Line";
        AssignedID: Code[50];
        SortActivity: Option " ",Item,Document,"Shelf or Bin","Due Date",Destination,"Bin Ranking","Action Type";
        QtyToPick: Decimal;
        PrintDoc: Boolean;
        EverythingHandled: Boolean;
        WhseWkshLineFound: Boolean;
        HideValidationDialog: Boolean;
        DoNotFillQtytoHandle: Boolean;
        BreakbulkFilter: Boolean;
        QtyToPickBase: Decimal;
        CreatePickFromWhseShpt: Report "Whse.-Shipment - Create Pick";
        gblnPerSourceNo: Boolean;
        gblnPerLineNo: Boolean;
        gblnPerDest: Boolean;
        gblnPerItem: Boolean;
        gblnPerDefaultPickBin: Boolean;
        grecWhseShptLine: Record "Warehouse Shipment Line";
        grecBufferTemp: Record "Buffer ELA" temporary;
        gdlgWindow: Dialog;
        Text011: Label 'Nothing to handle.';
        Text012: Label 'Creating Picks...#1########';

    [Scope('Internal')]
    procedure SetWhseShipmentLine(var WhseShptLine2: Record "Warehouse Shipment Line"; WhseShptHeader2: Record "Warehouse Shipment Header")
    begin
        WhseShptLine.Copy(WhseShptLine2);
        WhseShptHeader := WhseShptHeader2;
        AssignedID := WhseShptHeader2."Assigned User ID";
        GetLocation(WhseShptLine."Location Code");
    end;

    [Scope('Internal')]
    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if Location.Code <> LocationCode then begin
            if LocationCode = '' then
                Clear(Location)
            else
                Location.Get(LocationCode);
        end;
    end;

    [Scope('Internal')]
    procedure Initialize(AssignedID2: Code[20]; SortActivity2: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type"; PrintDoc2: Boolean; DoNotFillQtytoHandle2: Boolean; BreakbulkFilter2: Boolean)
    begin
        AssignedID := AssignedID2;
        SortActivity := SortActivity2;
        PrintDoc := PrintDoc2;
        DoNotFillQtytoHandle := DoNotFillQtytoHandle2;
        BreakbulkFilter := BreakbulkFilter2;
    end;
}

