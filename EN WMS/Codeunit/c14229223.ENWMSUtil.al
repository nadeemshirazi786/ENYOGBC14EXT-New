//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Codeunit EN WMS Util (ID 14229203).
/// </summary>
codeunit 14229223 "WMS Util ELA"
{
    trigger OnRun()
    begin

    end;

    var
        TEXT14229213: TextConst ENU = '%1 User %2 %3';

    procedure GetActivityType(ActivityType: Text[30]; var ActivityTypeOption: Enum "WMS Activity Type ELA")
    var
        ENWmsActType: Enum "WMS Activity Type ELA";
    begin
        CASE ActivityType OF
            'Putaway', 'Put-away', 'Put_away':
                ActivityTypeOption := ENWmsActType::"Put-away";
            'Pick':
                ActivityTypeOption := ENWmsActType::Pick;
            'Movement':
                ActivityTypeOption := ENWmsActType::Movement;
            'InvtPutaway':
                ActivityTypeOption := ENWmsActType::"Invt. Put-away";
            'InvtPick':
                ActivityTypeOption := ENWmsActType::"Invt. Pick";
            '':
                ActivityTypeOption := ENWmsActType::"Blank";
        END;
    end;

    procedure AddWhseComment(DocumentNo: Code[20]; DocumentLineNo: Integer; TableName: Enum "WMS Document Type ELA";
ActivityType: Enum "WMS Activity Type ELA";
                                                                                           AppUserID: Code[10];
                                                                                           Msg: Text[250])
    var
        WhseCommentLine: record "Warehouse Comment Line";
        NextCommentLineNo: integer;
    begin
        WhseCommentLine.RESET;
        WhseCommentLine.SETRANGE("Table Name", TableName);
        WhseCommentLine.SETRANGE(Type, ActivityType);
        WhseCommentLine.SETRANGE("No.", DocumentNo);
        IF WhseCommentLine.FINDLAST THEN
            NextCommentLineNo := WhseCommentLine."Line No." + 10000
        ELSE
            NextCommentLineNo := 10000;

        WhseCommentLine.INIT;
        EVALUATE(WhseCommentLine."Table Name", FORMAT(TableName));
        EVALUATE(WhseCommentLine.Type, FORMAT(ActivityType)); //WhseCommentLine.Type::" "; 
        WhseCommentLine."No." := DocumentNo;
        WhseCommentLine."Line No." := NextCommentLineNo;
        WhseCommentLine.Date := TODAY;
        WhseCommentLine.Comment :=
          STRSUBSTNO(TEXT14229213, FORMAT(TIME), AppUserID, Msg);
        IF WhseCommentLine.INSERT THEN;
    end;

    local procedure AddSalesDocComment(DocumentNo: Code[20]; DocumentLineNo: Integer;
    SalesDocType: Enum "WMS Sales Document Type ELA"; AppUserID: Code[10]; Msg: text[250])
    var
        SalesCommentLine: Record "Sales Comment Line";
        SalesDoc: Record "Sales Header";
        NextCommentLineNo: integer;
    begin
        SalesDoc.init;
        SalesDoc."No." := DocumentNo;
        Evaluate(SalesDoc."Document Type", Format(SalesDocType));

        SalesCommentLine.RESET;
        SalesCommentLine.SETRANGE("Document Type", SalesDoc."Document Type");
        SalesCommentLine.SETRANGE("No.", DocumentNo);
        IF SalesCommentLine.FINDLAST THEN
            NextCommentLineNo := SalesCommentLine."Line No." + 10000
        ELSE
            NextCommentLineNo := 10000;

        SalesCommentLine.INIT;
        SalesCommentLine."Document Type" := SalesCommentLine."Document Type"::Order;
        SalesCommentLine."No." := DocumentNo;
        SalesCommentLine."Line No." := NextCommentLineNo;
        SalesCommentLine.Date := TODAY;
        SalesCommentLine.Comment :=
          STRSUBSTNO(TEXT14229213, FORMAT(TIME), AppUserID, Msg);
        IF SalesCommentLine.INSERT THEN;

    end;

    procedure GetWHEmployeeLocationFilter(): Text
    var
        WarehouseEmployee: record "Warehouse Employee";
        LocationFilter: text;
    begin
        WarehouseEmployee.reset;
        WarehouseEmployee.SETRANGE("User ID", USERID);
        if WarehouseEmployee.FindSet() then begin
            repeat
                LocationFilter := LocationFilter + '|';
                if WarehouseEmployee."Location Code" = '' then
                    LocationFilter := LocationFilter + ''''''
                else
                    LocationFilter := LocationFilter + WarehouseEmployee."Location Code";
            UNTIL WarehouseEmployee.NEXT = 0;
            LocationFilter := COPYSTR(LocationFilter, 2);
            exit(LocationFilter);
        end else
            exit('');
    end;

    procedure LookupWHEmployeeLocation(var Text: Text): Boolean
    var
        Location: record Location;
        LocationList: page "Location List";
    begin
        Location.FILTERGROUP(9);
        Location.SETFILTER(Code, GetWHEmployeeLocationFilter);
        Location.SETRANGE("Use As In-Transit", FALSE);
        Location.FILTERGROUP(0);

        LocationList.LOOKUPMODE(TRUE);
        LocationList.SETTABLEVIEW(Location);
        if LocationList.RUNMODAL = ACTION::LookupOK then begin
            LocationList.GETRECORD(Location);
            Text := Location.Code;
            exit(TRUE);
        end else
            exit(FALSE);

    end;

    /// <summary>
    /// GetItemBulkUOMDetail.
    /// </summary>
    /// <param name="ItemNo">code[20].</param>
    /// <param name="UnitOfMeasureCode">VAR Code[10].</param>
    /// <param name="QtyPerBaseUnit">VAR Decimal.</param>
    procedure GetItemBulkUOMDetail(ItemNo: code[20]; var UnitOfMeasureCode: Code[10]; var QtyPerBaseUnit: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitOfMeasure.reset;
        ItemUnitOfMeasure.setrange("Item No.", ItemNo);
        ItemUnitOfMeasure.SetRange("Is Bulk ELA", true);
        if ItemUnitOfMeasure.FindFirst() then begin
            UnitOfMeasureCode := ItemUnitOfMeasure.Code;
            QtyPerBaseUnit := ItemUnitOfMeasure."Qty. per Unit of Measure";
        end else
            QtyPerBaseUnit := 1;
    end;


    /// <summary>
    /// ReleaseSalesDocument.
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    procedure ReleaseSalesDocument(var SalesHeader: Record "Sales Header")
    var
        RelSalesDoc: Codeunit "Release Sales Document";
        SalesLine: Record "Sales Line";
    begin
        SalesLine.reset;
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETFILTER(Type, '>0');
        SalesLine.SETFILTER(Quantity, '<>0');
        IF NOT SalesLine.FIND('-') THEN
            exit
        else
            RelSalesDoc.Run(SalesHeader);
    end;

}