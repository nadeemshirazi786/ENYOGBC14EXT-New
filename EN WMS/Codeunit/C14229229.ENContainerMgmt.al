//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Codeunit EN License Plate Mgmt. (ID 14229224).
/// </summary>
codeunit 14229229 "Container Mgmt. ELA"
{
    var
        Container: record "Container ELA";
        TEXT14229220: Label 'Container %1 is closed.';
        TEXT14229221: Label 'Quantity in Container %1 Item No. %2 cannot be less than 0.';

    /// <summary>
    /// AddContentToContainer.
    /// </summary>
    /// <param name="ContainerNo">code[20].</param>
    /// <param name="ItemNo">code[20].</param>
    /// <param name="UOM">code[10].</param>
    /// <param name="Quantity">Decimal.</param>
    /// <param name="VendorLotNo">code[20].</param>
    /// <param name="DocumentNo">code[20].</param>
    /// <param name="DocumentLineNo">Integer.</param>
    /// <param name="WhseDocType">Enum "EN Whse. Doc. Type".</param>
    /// <param name="WhseDocNo">COde[20].</param>
    /// <param name="ActivityType">Enum "EN WMS Activity Type".</param>
    /// <param name="ActivityNo">code[20].</param>
    /// <param name="ActivityLineNo">Integer.</param>
    procedure AddContentToContainer(ContainerNo: code[20]; ItemNo: code[20]; UOM: code[10]; Quantity: Decimal; VendorLotNo: code[20];
        DocumentNo: code[20]; DocumentLineNo: Integer; WhseDocType: Enum "Whse. Doc. Type ELA"; WhseDocNo: COde[20];
        ActivityType: Enum "WMS Activity Type ELA"; ActivityNo: code[20]; ActivityLineNo: Integer)
    var
        ContainerContent: record "Container Content ELA";
        ContainerContent2: Record "Container Content ELA";
        WhseActLine: record "Warehouse Activity Line";
        WhseActLine2: Record "Warehouse Activity Line";
        NextLineNo: Integer;
        TakeLineNo: Integer;
        PlaceLineNo: Integer;
    begin
        if IsContainerClosed(ContainerNo, Container) then
            if Container.Closed then
                Error(strsubstno(TEXT14229220, ContainerNo));

        if Quantity > 0 then begin
            ContainerContent2.reset;
            ContainerContent2.SetRange("Container No.", ContainerNo);
            if ContainerContent2.FindLast() then
                NextLineNo := ContainerContent2."Line No." + 10000
            else
                NextLineNo := 10000;

            ContainerContent.Init();
            ContainerContent."Container No." := ContainerNo;
            ContainerContent."Line No." := NextLineNo;
            ContainerContent.validate("Item No.", ItemNo);
            ContainerContent.validate("Unit of Measure", UOM);
            ContainerContent.validate(Quantity, Quantity);
            ContainerContent."Vendor Lot No." := VendorLotNo;
            ContainerContent."Location Code" := Container."Location Code";
            ContainerContent."Document No." := DocumentNo;
            ContainerContent."Document Line No." := DocumentLineNo;
            ContainerContent."Whse. Document Type" := WhseDocType;
            ContainerContent."Whse. Document No." := WhseDocNo;
            ContainerContent."Activity Type" := ActivityType;
            ContainerContent."Activity No." := ActivityNo;
            ContainerContent."Activity Line No." := ActivityLineNo;
            ContainerContent.Insert(true);

            if (ActivityNo <> '') and (ActivityLineNo <> 0) then begin
                IF WhseActLine.Get(ActivityType, ActivityNo, ActivityLineNo) then begin
                    GetWhseTakePlaceLineNo(WhseActLine, TakeLineNo, PlaceLineNo);
                    if WhseActLine."Activity Type" = WhseActLine."Activity Type"::Pick then begin
                        if (WhseActLine."Action Type" = WhseActLine."Action Type"::Take) then begin
                            ContainerContent."Bin Code" := WhseActLine."Bin Code";
                            ContainerContent."Trip No." := WhseActLine."Trip No. ELA";
                            ContainerContent.Modify();

                            if WhseActLine2.Get(ActivityType, ActivityNo, PlaceLineNo) then begin
                                RemoveContentToContainerFromLineNo(WhseActLine2."Container No. ELA", WhseActLine2."Container Line No. ELA");
                                WhseActLine2."Container No. ELA" := ContainerContent."Container No.";
                                WhseActLine2."Licnese Plate No. ELA" := ContainerContent."License Plate No.";
                                WhseActLine2."Container Line No. ELA" := ContainerContent."Line No.";
                                WhseActLine2.Modify();
                            end;
                        end else
                            if (WhseActLine."Action Type" = WhseActLine."Action Type"::Place) then begin
                                if WhseActLine2.Get(ActivityType, ActivityNo, TakeLineNo) then begin
                                    RemoveContentToContainerFromLineNo(WhseActLine2."Container No. ELA", WhseActLine2."Container Line No. ELA");
                                    WhseActLine2."Container No. ELA" := ContainerContent."Container No.";
                                    WhseActLine2."Licnese Plate No. ELA" := ContainerContent."License Plate No.";
                                    WhseActLine2."Container Line No. ELA" := ContainerContent."Line No.";
                                    WhseActLine2.Modify();
                                end;
                            end;
                        //RemoveContentToContainerFromLineNo(WhseActLine2."Container No. ELA", WhseActLine2."Container Line No. ELA");
                        WhseActLine."Container No. ELA" := ContainerContent."Container No.";
                        WhseActLine."Licnese Plate No. ELA" := ContainerContent."License Plate No.";
                        WhseActLine."Container Line No. ELA" := ContainerContent."Line No.";
                        WhseActLine.Modify();
                    end;
                end;
                /* WhseActLine.Reset();
                 WhseActLine.SetRange("Activity Type", ActivityType);
                 WhseActLine.SetRange("No.", ActivityNo);
                 WhseActLine.SetRange("Source No.", ContainerContent."Document No.");
                 WhseActLine.SetRange("Source Line No.", ContainerContent."Document Line No.");
                 // WhseActLine.SetRange("Line No.", ActivityLineNo);
                 if WhseActLine.FindSet() then
                     repeat
                         if WhseActLine."Activity Type" = WhseActLine."Activity Type"::Pick then
                             if (WhseActLine."Action Type" = WhseActLine."Action Type"::Take) then begin
                                 ContainerContent."Bin Code" := WhseActLine."Bin Code";
                                 ContainerContent."Trip No." := WhseActLine."Trip No.";
                                 ContainerContent.Modify();
                             end;

                         WhseActLine."Container No." := ContainerContent."Container No.";
                         WhseActLine."Licnese Plate No." := ContainerContent."License Plate No.";
                         WhseActLine.Modify();

                     until WhseActLine.Next() = 0;*/
            end;
        end;
        //ContainerContent.Modify();
    end;

    local procedure GetRegWhseTakePlaceLineNo(RegisterWhseActLine: Record "Registered Whse. Activity Line"; Var TakeLine: Integer; var PlaceLine: Integer)
    var
        RgWhActLine: Record "Registered Whse. Activity Line";
    begin
        IF RegisterWhseActLine."Action Type" = RegisterWhseActLine."Action Type"::Take THEN begin
            RgWhActLine.RESET;
            RgWhActLine.SetRange("No.", RegisterWhseActLine."No.");
            RgWhActLine.SetRange("Parent Line No. ELA", RegisterWhseActLine."Line No.");
            IF RgWhActLine.FindFirst() THEN begin
                TakeLine := RgWhActLine."Parent Line No. ELA";
                PlaceLine := RgWhActLine."Line No.";
            end;
        end;
    end;

    local procedure GetWhseTakePlaceLineNo(WhseActLine: Record "Warehouse Activity Line"; Var TakeLine: Integer; var PlaceLine: Integer)
    var
        WhActLine: Record "Warehouse Activity Line";
    begin
        IF WhseActLine."Action Type" = WhseActLine."Action Type"::Take THEN begin
            WhActLine.RESET;
            WhActLine.SetRange("No.", WhseActLine."No.");
            WhActLine.SetRange("Parent Line No. ELA", WhseActLine."Line No.");
            IF WhActLine.FindFirst() THEN begin
                TakeLine := WhActLine."Parent Line No. ELA";
                PlaceLine := WhActLine."Line No.";
            end;
        end;
    end;

    /// <summary>
    /// AssignLicensePlateToContainer.
    /// </summary>
    /// <param name="ContainerNo">code[20].</param>
    /// <param name="LicensePlateNo">code[20].</param>
    procedure AssignLicensePlateToContainer(ContainerNo: code[20]; LicensePlateNo: code[20])
    var

        ContainerContents: Record "Container Content ELA";
        LicesnsePlate: record "License Plate ELA";
        LicensePlateMgmt: Codeunit "License Plate Mgmt. ELA";
    begin
        IsContainerClosed(ContainerNo, Container);

        if not LicesnsePlate.get(LicensePlateNo) then
            LicensePlateNo := LicensePlateMgmt.CreateNewLicensePlate(LicensePlateNo, Container."Container Type");

        ContainerContents.reset;
        ContainerContents.setrange("Container No.", ContainerNo);
        if ContainerContents.FindSet() then
            repeat
                ContainerContents."License Plate No." := LicensePlateNo;
                ContainerContents.Modify();
            until ContainerContents.Next() = 0;
    end;

    /// <summary>
    /// CloseContainer.
    /// </summary>
    /// <param name="ContainerNo">code[20].</param>
    procedure CloseContainer(ContainerNo: code[20])
    var
    begin
        GetContainer(ContainerNo);
        Container.Closed := true;
        Container.Modify(true);
    end;

    /// <summary>
    /// CreateNewContainer.
    /// </summary>
    /// <param name="ContainerType">code[20].</param>
    /// <param name="SourceDocType">Enum "EN WMS Source Doc Type".</param>
    /// <param name="DocumentType">integer.</param>
    /// <param name="DocumentNo">code[20].</param>
    /// <param name="WhseDocType">Enum "EN Whse. Doc. Type".</param>
    /// <param name="WhseDocNo">code[20].</param>
    /// <param name="WhseActivityType">Enum "EN WMS Activity Type".</param>
    /// <param name="WhseActivityNo">Code[20].</param>
    /// <param name="Location">code[20].</param>
    /// <param name="ShowContainer">Boolean.</param>
    /// <returns>Return value of type code[20].</returns>
    procedure CreateNewContainer(ContainerType: code[20]; Location: code[20]; ShowContainer: Boolean): Code[20]
    var
        Container: record "Container ELA";
        SalesHeader: Record "Sales Header";
    begin

        /*if TripNo = '' then
            if SourceDocType = SourceDocType::"Sales Order" then
                if SalesHeader.get(SalesHeader."Document Type"::Order, DocumentNo) then
                    TripNo := SalesHeader."Trip No.";*/

        Container.Init();
        //Container."Trip No." := TripNo;
        Container."Container Type" := ContainerType;
        //Container.Validate("Source Document Type", SourceDocType);
        //Container."Document Type" := DocumentType;
        //."Document No." := DocumentNo;
        Container.validate("Location Code", Location);
        //Container."Whse. Document Type" := WhseDocType;
        //Container.validate("Whse. Document No.", WhseDocNo);
        // Container."Activity Type" := WhseActivityType;
        // Container."Activity No." := WhseActivityNo;
        container.Closed := false;
        Container.insert(true);
        exit(Container."No.");

        /* if ShowContainer then
             ShowContainer(SourceDocType, '', Location, DocumentType, DocumentNo, WhseDocType::Receipt, WhseDocNo,
                  WhseActivityType, WhseActivityNo)*/

    end;

    /// <summary>
    /// GenarateContainerContents.
    /// </summary>
    /// <param name="SourceDocTypeFilter">Enum "EN WMS Source Doc Type".</param>
    /// <param name="DocumentType">Option.</param>
    /// <param name="DocumentNo">Code[20].</param>
    /// <param name="LineNo">Integer.</param>
    /// <param name="ItemNo">Code[20].</param>
    /// <param name="UnitOfMeasure">Text[50].</param>
    /// <param name="QtyToReceive">Decimal.</param>
    /// <param name="TotalContainers">Decimal.</param>
    /// <param name="VendorLotNo">Code[20].</param>
    /// <param name="LocationCode">code[10].</param>
    procedure GenarateContainerContents(
        TripNo: Code[20];
        SourceDocTypeFilter: Enum "WMS Source Doc Type ELA";
        DocumentType: Enum "WMS Sales Document Type ELA";
        DocumentNo: Code[20];
        LineNo: Integer;
        ItemNo: Code[20];
        UnitOfMeasure: Code[10];
        QtyToReceive: Decimal;
        TotalContainers: Decimal;
        VendorLotNo: Code[20];
        LocationCode: code[20];
        WhseDocType: Enum "Whse. Doc. Type ELA";
        WhseDocNo: Code[20];
        ActivityType: Enum "WMS Activity Type ELA";
        ActivityNo: code[20]
         )
    var
        count: Integer;
        Container: record "Container ELA";
        ContainerNo: code[20];
    begin

        //todo #21 @Kamranshehzad handle partial containers using auto generation
        case SourceDocTypeFilter of
            SourceDocTypeFilter::"Purchase Order":
                begin
                    for count := 1 to TotalContainers do begin
                        ContainerNo := CreateNewContainer('', LocationCode, false);
                        AddContentToContainer(ContainerNo, ItemNo, UnitOfMeasure, QtyToReceive, VendorLotNo, DocumentNo, LineNo,
                        WhseDocType, WhseDocNo, ActivityType, ActivityNo, 0);
                    end;
                end;

            SourceDocTypeFilter::"Sales Order":
                begin
                    for count := 1 to TotalContainers do begin
                        ContainerNo := CreateNewContainer('', LocationCode, false);
                        AddContentToContainer(ContainerNo, ItemNo, UnitOfMeasure, QtyToReceive, '', DocumentNo, LineNo,
                        WhseDocType, WhseDocNo, ActivityType, ActivityNo, 0);
                    end;
                end;
        end;
    end;


    /// <summary>
    /// GetQtyFromContainers.
    /// </summary>
    /// <param name="SourceDocumentType">ENUM "EN WMS Source Doc Type".</param>
    /// <param name="DocumentType">Enum "EN WMS Sales Document Type".</param>
    /// <param name="DocumentNo">Code[20].</param>
    /// <param name="ItemNo">code[20].</param>
    /// <param name="UnitOfMeasure">code[10].</param>
    /// <returns>Return value of type Decimal.</returns>
    procedure GetQtyFromContainers(
            SourceDocumentType: ENUM "WMS Source Doc Type ELA";
            DocumentType: Enum "WMS Sales Document Type ELA";
            DocumentNo: Code[20];
            WhseDocType: Enum "Whse. Doc. Type ELA";
            WhseDocNo: code[20];
            WhseActType: Enum "WMS Activity Type ELA";
            WhseActNo: code[20];
            ItemNo: code[20];
            UnitOfMeasure: code[10]): Decimal
    var

        ContainerContents: record "Container Content ELA";
        QtyOnContainer: Decimal;
    begin
        ContainerContents.Reset();
        ContainerContents.SetRange("Document Type", SourceDocumentType);
        ContainerContents.SetRange("Document Type", DocumentType);
        ContainerContents.SetRange("Document No.", DocumentNo);
        if WhseDocNo <> '' then begin
            ContainerContents.SetRange("Whse. Document Type", WhseDocType);
            ContainerContents.SetRange("Whse. Document No.", WhseDocNo);
        end;

        if WhseActNo <> '' then begin
            ContainerContents.SetRange("Activity Type", WhseActType);
            ContainerContents.SetRange("Activity No.", WhseActNo);
        end;
        // Container.SetRange(Closed, false);
        if Container.FindSet() then
            repeat
                ContainerContents.SetRange("Container No.", Container."No.");
                ContainerContents.SetRange("Item No.", ItemNo);
                ContainerContents.SetRange("Unit of Measure", UnitOfMeasure);
                if ContainerContents.FindSet() then
                    repeat
                        QtyOnContainer += ContainerContents.Quantity;
                    until ContainerContents.Next() = 0;
            until Container.Next() = 0;

        exit(QtyOnContainer);
    end;

    procedure MergeLicensePlateLines()
    var
        myInt: Integer;
    begin

    end;

    /// <summary>
    /// RemoveContentToContainer.
    /// </summary>
    /// <param name="ContainerNo">code[20].</param>
    /// <param name="ItemNo">code[20].</param>
    /// <param name="UOM">code[10].</param>
    /// <param name="Quantity">Decimal.</param>
    procedure RemoveContentToContainer(ContainerNo: code[20]; ItemNo: code[20]; UOM: code[10]; Quantity: Decimal)
    var

        ContainerContent: record "Container Content ELA";
    begin
        GetContainer(ContainerNo);
        ContainerContent.SetRange("Container No.", ContainerNo);
        ContainerContent.SetRange("Item No.", ItemNo);
        ContainerContent.setrange("Unit of Measure", UOM);
        if ContainerContent.FindFirst() then begin
            if ContainerContent.Quantity - Quantity = 0 then
                ContainerContent.Delete()
            else begin
                if ContainerContent.Quantity - Quantity < 0 then
                    error(strsubstno(TEXT14229221, ContainerNo, ItemNo));

                ContainerContent.Quantity := ContainerContent.Quantity - Quantity;
                ContainerContent.Modify();
            end;
        end;
    end;

    procedure RemoveContentToContainerFromLineNo(ContainerNo: code[20]; LineNo: Integer)
    var

        ContainerContent: record "Container Content ELA";
    begin
        If ContainerContent.Get(ContainerNo, LineNo) then begin
            if (ContainerContent."Activity Type" = ContainerContent."Activity Type"::"Put-away") OR (ContainerContent."Activity Type" = ContainerContent."Activity Type"::"Invt. Put-away") then begin
                ContainerContent."Activity Type" := 0;
                ContainerContent."Activity No." := '';
                ContainerContent."Activity Line No." := 0;
                ContainerContent.Modify();
            end else
                if (ContainerContent."Activity Type" = ContainerContent."Activity Type"::"Pick") OR (ContainerContent."Activity Type" = ContainerContent."Activity Type"::"Invt. Pick") then begin
                    ContainerContent.Delete();
                end;

        end;
    end;

    /// <summary>
    /// ReOpenContainer.
    /// </summary>
    /// <param name="ContainerNo">code[20].</param>
    procedure ReOpenContainer(ContainerNo: code[20])
    var

    begin
        GetContainer(ContainerNo);
        Container.Closed := false;
        Container.Modify(true);
    end;

    /// <summary>
    /// ShowContainer.
    /// </summary>
    /// <param name="SourceDocTypeFilter">Enum "EN WMS Source Doc Type".</param>
    /// <param name="ContainerNo">code[20].</param>
    /// <param name="LocationCode">Code[10].</param>
    /// <param name="DocumentType">Integer.</param>
    /// <param name="DocumentNo">code[20].</param>
    /// <param name="WhseDocType">Enum "EN Whse. Doc. Type".</param>
    /// <param name="WhseDocNo">Code[20].</param>
    /// <param name="WhseActType">enum "EN WMS Activity Type".</param>
    /// <param name="WhseActNo">Code[20].</param>
    /// 
    procedure ShowContainer(SourceDocTypeFilter: Enum "WMS Source Doc Type ELA"; ContainerNo: code[20]; LocationCode: Code[10];
         DocumentType: Enum "WMS Sales Document Type ELA"; DocumentNo: code[20]; WhseDocType: Enum "Whse. Doc. Type ELA";
         WhseDocNo: Code[20]; WhseActType: enum "WMS Activity Type ELA"; WhseActNo: Code[20])
    var
        ContainerContent: record "Container Content ELA";
        ContainersContentList: Page "Containers Contents ELA";
        ContMgmt: Codeunit "Container Mgmt. ELA";
    begin
        /*To Review if ContainerNo <> '' then begin
            GetContainer(ContainerNo);
        end else begin*/
        ContainerContent.reset;
        // Container.SetRange("Location Code", LocationCode);
        if DocumentNo <> '' then
            ContainerContent.SetRange("Document No.", DocumentNo);

        // To Review end;

        if (WhseDocNo <> '') then begin
            ContainerContent.SetRange("Whse. Document Type", WhseDocType);
            ContainerContent.SetRange("Whse. Document No.", WhseDocNo);
        end;

        if WhseActNo <> '' then begin
            ContainerContent.SetRange("Activity Type", WhseActType);
            ContainerContent.SetRange("Activity No.", WhseActNo);
        end;
        if ContainerContent.FindFirst() then
            ContainersContentList.SetTableView(ContainerContent)
        else begin
            if (Confirm(StrSubstNo('No Container found for this document %1. Do you want to Create one?', DocumentNo), false)) then begin
                ContainerNo :=
                    CreateNewContainer('', LocationCode, true);
                GetContainer(ContainerNo);
                ContainersContentList.SetTableView(ContainerContent)
            end else
                Error('');
        end;

        ContainersContentList.Run();
    end;

    /* procedure ShowContainer(SourceDocTypeFilter: Enum "EN WMS Source Doc Type"; ContainerNo: code[20]; LocationCode: Code[10];
         DocumentType: Enum "EN WMS Sales Document Type"; DocumentNo: code[20]; WhseDocType: Enum "EN Whse. Doc. Type";
         WhseDocNo: Code[20]; WhseActType: enum "EN WMS Activity Type"; WhseActNo: Code[20])
    var
        Container: record "EN Container";
        ContainersList: Page "EN Containers";
        ContMgmt: Codeunit "EN Container Mgmt.";
    begin
        if ContainerNo <> '' then begin
             GetContainer(ContainerNo);
         end else begin
             Container.reset;
             // Container.SetRange("Location Code", LocationCode);
             case SourceDocTypeFilter of
                 SourceDocTypeFilter::"Purchase Order":
                     if (DocumentType = DocumentType::Order) and (DocumentNo <> '') then begin
                         Container.setrange("Source Document Type", SourceDocTypeFilter::"Purchase Order");
                         Container.SetRange("Document Type", DocumentType);
                         Container.SetRange("Document No.", DocumentNo);
                     end;

                 SourceDocTypeFilter::"Sales Order":
                     if (DocumentType = DocumentType::Order) and (DocumentNo <> '') then begin
                         Container.setrange("Source Document Type", SourceDocTypeFilter::"Sales Order");
                         Container.SetRange("Document Type", DocumentType);
                         Container.SetRange("Document No.", DocumentNo);
                     end;
             end;
         end;

         if (WhseDocNo <> '') then begin
             Container.SetRange("Whse. Document Type", WhseDocType);
             Container.SetRange("Whse. Document No.", WhseDocNo);
         end;

         if WhseActNo <> '' then begin
             container.SetRange("Activity Type", WhseActType);
             Container.SetRange("Activity No.", WhseActNo);
         end;
         if Container.FindFirst() then
             ContainersList.SetTableView(Container)
         else begin
             if (Confirm(StrSubstNo('No Container found for this document %1. Do you want to Create one?', DocumentNo), false)) then begin
                 ContainerNo :=
                     CreateNewContainer('', '', SourceDocTypeFilter, DocumentType, DocumentNo, WhseDocType, WhseDocNo,
                          WhseActType, WhseActNo, LocationCode, true);
                 GetContainer(ContainerNo);
                 ContainersList.SetTableView(Container)
             end else
                 Error('');
         end;

         ContainersList.Run();
    end;*/



    /// <summary>
    /// ShowTripContainers.
    /// </summary>
    /// <param name="TripNo">code[20].</param>
    procedure ShowTripContainers(TripNo: code[20])
    var
        Container: record "Container ELA";
        ContainersList: Page "Containers ELA";
    begin
        /* Container.SetRange("Trip No.", TripNo);
         Container.FindSet();
         ContainersList.SetTableView(Container);
         ContainersList.Run();*/
    end;

    local procedure GetContainer(ContainerNo: code[20])
    var
    begin
        if Container.Get(ContainerNo) then;
    end;

    /// <summary>
    /// CheckContainerStatus.
    /// </summary>
    /// <param name="ContainerNo">code[20].</param>
    /// <param name="Container">VAR record "EN Container".</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure IsContainerClosed(ContainerNo: code[20]; var Container: record "Container ELA"): Boolean
    begin
        GetContainer(ContainerNo);
        exit(Container.Closed);
        // if Container.Closed then
        // Error(strsubstno(TEXT14229220, ContainerNo));
    end;
}
