codeunit 14229101 "EN Extra Charge Functions"
{
    trigger OnRun()
    begin

    end;

    

    procedure CopyFromPurchECToHeader(VAR ToPurchHeader: Record "Purchase Header"; VAR FromPurchHeader: Record "Purchase Header")
    var
        myInt: Integer;
    begin
        IF NOT (ToPurchHeader."Document Type" IN [ToPurchHeader."Document Type"::Order,
            ToPurchHeader."Document Type"::Invoice])
        THEN
            EXIT;
        //IF NOT ProcessFns.FreshProInstalled THEN
          //  EXIT;

        ExtraChargeMgmt.CopyFromPurchHeader(ToPurchHeader, FromPurchHeader, RecalculateLines);
    end;

    procedure CopyFromPstdPurchECToHeader(VAR ToPurchHeader: Record "Purchase Header"; TableID: Integer; DocNo: Code[20])
    var
        LineNo: Integer;
    begin
        IF NOT (ToPurchHeader."Document Type" IN [ToPurchHeader."Document Type"::Order,
            ToPurchHeader."Document Type"::Invoice])
        THEN
            EXIT;
        //IF NOT ProcessFns.FreshProInstalled THEN
          //  EXIT;

        ExtraChargeMgmt.CopyFromPostedPurchDocHeader(ToPurchHeader, TableID, DocNo, RecalculateLines);
    end;

    procedure CopyFromPurchECToLine(VAR ToPurchLine: Record "Purchase Line"; VAR FromPurchLine: Record "Purchase Line")
    var
        myInt: Integer;
    begin
        IF NOT (ToPurchLine."Document Type" IN [ToPurchLine."Document Type"::Order,
            ToPurchLine."Document Type"::Invoice, ToPurchLine."Document Type"::"Credit Memo",
            ToPurchLine."Document Type"::"Return Order"])
        THEN
            EXIT;
        //IF (NOT ProcessFns.FreshProInstalled) OR RecalculateLines THEN
          //  EXIT;

        ExtraChargeMgmt.CopyFromPurchLine(ToPurchLine, FromPurchLine);
    end;

    procedure CopyFromPstdPurchECToLine(VAR ToPurchLine: Record "Purchase Line"; FromDocType: Enum "EN Purchase Doc. Type"; VAR FromPurchRcptLine: Record "Purch. Rcpt. Line"; VAR FromPurchInvLine: Record "Purch. Inv. Line"; VAR FromReturnShptLine: Record "Return Shipment Line"; VAR FromPurchCrMemoLine: Record "Purch. Cr. Memo Line")
    var
        TableID: Integer;
        DocNo: Code[20];
        LineNo: Integer;
    begin
        IF NOT (ToPurchLine."Document Type" IN [ToPurchLine."Document Type"::Order,
            ToPurchLine."Document Type"::Invoice, ToPurchLine."Document Type"::"Credit Memo",
            ToPurchLine."Document Type"::"Return Order"])
        THEN
            EXIT;
        //IF (NOT ProcessFns.FreshProInstalled) OR RecalculateLines THEN
          //  EXIT;

        CASE FromDocType OF
            PurchDocType::"Posted Receipt":
                BEGIN
                    TableID := DATABASE::"Purch. Rcpt. Line";
                    DocNo := FromPurchRcptLine."Document No.";
                    LineNo := FromPurchRcptLine."Line No.";
                END;
            PurchDocType::"Posted Invoice":
                BEGIN
                    TableID := DATABASE::"Purch. Inv. Line";
                    DocNo := FromPurchInvLine."Document No.";
                    LineNo := FromPurchInvLine."Line No.";
                END;
            PurchDocType::"Posted Return Shipment":
                BEGIN
                    TableID := DATABASE::"Return Shipment Line";
                    DocNo := FromReturnShptLine."Document No.";
                    LineNo := FromReturnShptLine."Line No.";
                END;
            PurchDocType::"Posted Credit Memo":
                BEGIN
                    TableID := DATABASE::"Purch. Cr. Memo Line";
                    DocNo := FromPurchCrMemoLine."Document No.";
                    LineNo := FromPurchCrMemoLine."Line No.";
                END;
        END;

        ExtraChargeMgmt.CopyFromPostedPurchDocLine(ToPurchLine, TableID, DocNo, LineNo)

    end;

    procedure SetAccNo(VAR InvtPostBuf: Record "EN Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; AdditionalPostingCode: Code[20]; AccType: Enum "EN Posting Buffer Acc. Type"; BalAccType: Enum "EN Posting Buffer Acc. Type")
    var
        InvtPostSetup: Record "Inventory Posting Setup";
        GenPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        ECPostingSetup: Record "EN Extra Charge Posting Setup";
        Resource: Record Resource;
    begin
        //InvtPostBuf DO BEGIN
        InvtPostBuf."Account No." := '';
        InvtPostBuf."Account Type" := AccType;
        InvtPostBuf."Bal. Account Type" := BalAccType;
        InvtPostBuf."Location Code" := ValueEntry."Location Code";
        InvtPostBuf."Inventory Posting Group" :=
          GetInvPostingGroupCode(ValueEntry, AccType = InvtPostBuf."Account Type"::"WIP Inventory", ValueEntry."Inventory Posting Group");
        InvtPostBuf."Gen. Bus. Posting Group" := ValueEntry."Gen. Bus. Posting Group";
        // P8000466A
        IF InvtPostBuf.UseABCDetail THEN BEGIN
            Resource.GET(AdditionalPostingCode);
            InvtPostBuf."Gen. Prod. Posting Group" := Resource."Gen. Prod. Posting Group"
        END ELSE
            // P8000466A
            InvtPostBuf."Gen. Prod. Posting Group" := ValueEntry."Gen. Prod. Posting Group";
        InvtPostBuf."Posting Date" := ValueEntry."Posting Date";
        InvtPostBuf."Additional Posting Code" := AdditionalPostingCode; // P8000466A

        // P8000062B
        IF InvtPostBuf.UseECPostingSetup THEN BEGIN // P8000466A
            IF CalledFromItemPosting THEN
                ECPostingSetup.GET(InvtPostBuf."Gen. Bus. Posting Group", InvtPostBuf."Gen. Prod. Posting Group", InvtPostBuf."Additional Posting Code") // P8000466A
            ELSE
                IF NOT ECPostingSetup.GET(InvtPostBuf."Gen. Bus. Posting Group", InvtPostBuf."Gen. Prod. Posting Group", InvtPostBuf."Additional Posting Code") THEN // P8000466A
                    EXIT;
            // P8000062B
        END ELSE
            IF InvtPostBuf.UseInvtPostSetup THEN BEGIN // P8000062B
                IF CalledFromItemPosting THEN
                    InvtPostSetup.GET(InvtPostBuf."Location Code", InvtPostBuf."Inventory Posting Group")
                ELSE
                    IF NOT InvtPostSetup.GET(InvtPostBuf."Location Code", InvtPostBuf."Inventory Posting Group") THEN
                        EXIT;
            END ELSE BEGIN
                IF CalledFromItemPosting THEN
                    GenPostingSetup.GET(InvtPostBuf."Gen. Bus. Posting Group", InvtPostBuf."Gen. Prod. Posting Group")
                ELSE
                    IF NOT GenPostingSetup.GET(InvtPostBuf."Gen. Bus. Posting Group", InvtPostBuf."Gen. Prod. Posting Group") THEN
                        EXIT;
            END;

        CASE InvtPostBuf."Account Type" OF
            InvtPostBuf."Account Type"::Inventory:
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := InvtPostSetup.GetInventoryAccount
                ELSE
                    InvtPostBuf."Account No." := InvtPostSetup."Inventory Account";
            InvtPostBuf."Account Type"::"Inventory (Interim)":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := InvtPostSetup.GetInventoryAccountInterim
                ELSE
                    InvtPostBuf."Account No." := InvtPostSetup."Inventory Account (Interim)";
            InvtPostBuf."Account Type"::"WIP Inventory":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := InvtPostSetup.GetWIPAccount
                ELSE
                    InvtPostBuf."Account No." := InvtPostSetup."WIP Account";
            InvtPostBuf."Account Type"::"Material Variance":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := InvtPostSetup.GetMaterialVarianceAccount
                ELSE
                    InvtPostBuf."Account No." := InvtPostSetup."Material Variance Account";
            InvtPostBuf."Account Type"::"Capacity Variance":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := InvtPostSetup.GetCapacityVarianceAccount
                ELSE
                    InvtPostBuf."Account No." := InvtPostSetup."Capacity Variance Account";
            InvtPostBuf."Account Type"::"Subcontracted Variance":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := InvtPostSetup.GetSubcontractedVarianceAccount
                ELSE
                    InvtPostBuf."Account No." := InvtPostSetup."Subcontracted Variance Account";
            InvtPostBuf."Account Type"::"Cap. Overhead Variance":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := InvtPostSetup.GetCapOverheadVarianceAccount
                ELSE
                    InvtPostBuf."Account No." := InvtPostSetup."Cap. Overhead Variance Account";
            InvtPostBuf."Account Type"::"Mfg. Overhead Variance":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := InvtPostSetup.GetMfgOverheadVarianceAccount
                ELSE
                    InvtPostBuf."Account No." := InvtPostSetup."Mfg. Overhead Variance Account";
            InvtPostBuf."Account Type"::"Inventory Adjmt.":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := GenPostingSetup.GetInventoryAdjmtAccount
                ELSE
                    InvtPostBuf."Account No." := GenPostingSetup."Inventory Adjmt. Account";
            InvtPostBuf."Account Type"::"Direct Cost Applied":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := GenPostingSetup.GetDirectCostAppliedAccount
                ELSE
                    InvtPostBuf."Account No." := GenPostingSetup."Direct Cost Applied Account";
            InvtPostBuf."Account Type"::"Overhead Applied":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := GenPostingSetup.GetOverheadAppliedAccount
                ELSE
                    InvtPostBuf."Account No." := GenPostingSetup."Overhead Applied Account";
            // P8000375A
            /* InvtPostBuf."Account Type"::"ABC Direct":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := GenPostingSetup.GetABCDirectAccount // P80053245
                ELSE
                    InvtPostBuf."Account No." := GenPostingSetup."ABC Direct Account";
            InvtPostBuf."Account Type"::"ABC Overhead":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := GenPostingSetup.GetABCOverheadAccount // P80053245
                ELSE
                    InvtPostBuf."Account No." := GenPostingSetup."ABC Overhead Account"; */ //TBR
            // P8000375A
            InvtPostBuf."Account Type"::"Purchase Variance":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := GenPostingSetup.GetPurchaseVarianceAccount
                ELSE
                    InvtPostBuf."Account No." := GenPostingSetup."Purchase Variance Account";
            InvtPostBuf."Account Type"::COGS:
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := GenPostingSetup.GetCOGSAccount
                ELSE
                    InvtPostBuf."Account No." := GenPostingSetup."COGS Account";
            InvtPostBuf."Account Type"::"COGS (Interim)":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := GenPostingSetup.GetCOGSInterimAccount
                ELSE
                    InvtPostBuf."Account No." := GenPostingSetup."COGS Account (Interim)";
            InvtPostBuf."Account Type"::"Invt. Accrual (Interim)":
                IF CalledFromItemPosting THEN
                    InvtPostBuf."Account No." := GenPostingSetup.GetInventoryAccrualAccount
                ELSE
                    InvtPostBuf."Account No." := GenPostingSetup."Invt. Accrual Acc. (Interim)";
        // PR3.61.01 Begin
        /*InvtPostBuf."Account Type"::"Writeoff (Company)":
            IF CalledFromItemPosting THEN
                InvtPostBuf."Account No." := InvtPostSetup.GetWriteoffAccountCompany // P80053245
            ELSE
                InvtPostBuf."Account No." := InvtPostSetup."Writeoff Account (Company)";
        InvtPostBuf."Account Type"::"Writeoff (Vendor)":
            IF CalledFromItemPosting THEN
                InvtPostBuf."Account No." := InvtPostSetup.GetWriteoffAccountVendor // P80053245
            ELSE
                InvtPostBuf."Account No." := InvtPostSetup."Writeoff Account (Vendor)";
        // PR3.61.01 End
        // P8000062B Begin
        InvtPostBuf."Account Type"::"Invt. Accrual-EC (Interim)":
            IF CalledFromItemPosting THEN
                InvtPostBuf."Account No." := ECPostingSetup.GetInventoryAccrualAccount // P80053245
            ELSE
                InvtPostBuf."Account No." := ECPostingSetup."Invt. Accrual Acc. (Interim)"; 
        InvtPostBuf."Account Type"::"Direct Cost Applied-EC":
            IF CalledFromItemPosting THEN
                InvtPostBuf."Account No." := ECPostingSetup.GetDirectCostAppliedAccount // P80053245
            ELSE
                InvtPostBuf."Account No." := ECPostingSetup."Direct Cost Applied Account"; */ //TBR
                                                                                              // P8000062B End
        END;
        IF InvtPostBuf."Account No." <> '' THEN BEGIN
            GLAccount.GET(InvtPostBuf."Account No.");
            IF GLAccount.Blocked THEN BEGIN
                IF CalledFromItemPosting THEN
                    GLAccount.TESTFIELD(Blocked, FALSE);
                IF NOT CalledFromTestReport THEN
                    InvtPostBuf."Account No." := '';
            END;
        END;
        //OnAfterSetAccNo(InvtPostBuf, ValueEntry, CalledFromItemPosting);
    end;

    procedure GetInvPostingGroupCode(ValueEntry: Record "Value Entry"; WIPInventory: Boolean; InvPostingGroupCode: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        IF WIPInventory THEN
            IF ValueEntry."Source No." <> ValueEntry."Item No." THEN
                IF Item.GET(ValueEntry."Source No.") THEN
                    EXIT(Item."Inventory Posting Group");

        EXIT(InvPostingGroupCode);
    end;

    procedure BufferPurchPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; VAR ECToPost: Record "EN Extra Charge Posting Buffer" temporary)
    begin
        //WITH ValueEntry DO
        CASE ValueEntry."Entry Type" OF
            ValueEntry."Entry Type"::"Direct Cost":
                BEGIN
                    // PR4.00 Begin
                    IF ECToPost.FIND('-') THEN
                        REPEAT
                            IF (ECToPost."Cost To Post (Expected)" <> 0) OR (ECToPost."Cost To Post (Expected) (ACY)" <> 0) THEN BEGIN
                                // P8000466A
                                //UpdateInvtPostBufEC(
                                AdditionalPostingCode := ECToPost."Extra Charge Code";
                                InitInvtPostBuffer(
                                  // P8000466A
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                                  GlobalInvtPostBuf."Account Type"::"Invt. Accrual-EC (Interim)",
                                  //ECToPost."Extra Charge Code", // P8000466A
                                  ECToPost."Cost To Post (Expected)", ECToPost."Cost To Post (Expected) (ACY)", TRUE);
                                ExpCostToPost -= ECToPost."Cost To Post (Expected)";
                                ExpCostToPostACY -= ECToPost."Cost To Post (Expected) (ACY)";
                            END;
                            IF (ECToPost."Cost To Post" <> 0) OR (ECToPost."Cost To Post (ACY)" <> 0) THEN BEGIN
                                // P8000466A
                                //UpdateInvtPostBufEC(
                                AdditionalPostingCode := ECToPost."Extra Charge Code";
                                InitInvtPostBuffer(
                                  // P8000466A
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Direct Cost Applied-EC",
                                  //ECToPost."Extra Charge Code", // P8000466A
                                  ECToPost."Cost To Post", ECToPost."Cost To Post (ACY)", FALSE);
                                CostToPost -= ECToPost."Cost To Post";
                                CostToPostACY -= ECToPost."Cost To Post (ACY)";
                            END;
                        UNTIL ECToPost.NEXT = 0;
                    // PR4.00 End
                    IF (ExpCostToPost <> 0) OR (ExpCostToPostACY <> 0) THEN
                        InitInvtPostBuffer(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                          GlobalInvtPostBuf."Account Type"::"Invt. Accrual (Interim)",
                          ExpCostToPost, ExpCostToPostACY, TRUE);
                    IF (CostToPost <> 0) OR (CostToPostACY <> 0) THEN
                        InitInvtPostBuffer(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::Inventory,
                          GlobalInvtPostBuf."Account Type"::"Direct Cost Applied",
                          CostToPost, CostToPostACY, FALSE);
                END;
            ValueEntry."Entry Type"::"Indirect Cost":
                InitInvtPostBuffer(
                  ValueEntry,
                  GlobalInvtPostBuf."Account Type"::Inventory,
                  GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                  CostToPost, CostToPostACY, FALSE);
            ValueEntry."Entry Type"::Variance:
                BEGIN
                    ValueEntry.TESTFIELD("Variance Type", ValueEntry."Variance Type"::Purchase);
                    InitInvtPostBuffer(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Purchase Variance",
                      CostToPost, CostToPostACY, FALSE);
                END;
            ValueEntry."Entry Type"::Revaluation:
                BEGIN
                    IF (ExpCostToPost <> 0) OR (ExpCostToPostACY <> 0) THEN
                        InitInvtPostBuffer(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                          GlobalInvtPostBuf."Account Type"::"Invt. Accrual (Interim)",
                          ExpCostToPost, ExpCostToPostACY, TRUE);
                    IF (CostToPost <> 0) OR (CostToPostACY <> 0) THEN
                        InitInvtPostBuffer(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::Inventory,
                          GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                          CostToPost, CostToPostACY, FALSE);
                END;
            ValueEntry."Entry Type"::Rounding:
                InitInvtPostBuffer(
                  ValueEntry,
                  GlobalInvtPostBuf."Account Type"::Inventory,
                  GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                  CostToPost, CostToPostACY, FALSE);
            ELSE
                ErrorNonValidCombination(ValueEntry);

        END;
    end;

    procedure BufferAdjmtPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; VAR ECToPost: Record "EN Extra Charge Posting Buffer" TEMPORARY)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        WITH ValueEntry DO
            CASE "Entry Type" OF
                "Entry Type"::"Direct Cost":
                    BEGIN
                        // Posting adjustments to Interim accounts (Service)
                        IF (ExpCostToPost <> 0) OR (ExpCostToPostACY <> 0) THEN
                            InitInvtPostBuffer(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"COGS (Interim)",
                              ExpCostToPost, ExpCostToPostACY, TRUE);
                        IF (CostToPost <> 0) OR (CostToPostACY <> 0) THEN
                        // PR3.61.01 Begin
                        //  InitInvtPostBuf(
                        //    ValueEntry,
                        //    GlobalInvtPostBuf."Account Type"::Inventory,
                        //    GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                        //    CostToPost,CostToPostACY,FALSE);
                        BEGIN
                            ItemLedgerEntry.GET("Item Ledger Entry No.");
                            CASE ItemLedgerEntry."Writeoff Responsibility ELA" OF
                                ItemLedgerEntry."Writeoff Responsibility ELA"::" ":
                                    // P8000928
                                    BEGIN
                                        IF ECToPost.FIND('-') THEN
                                            REPEAT
                                                IF (ECToPost."Cost To Post" <> 0) OR (ECToPost."Cost To Post (ACY)" <> 0) THEN BEGIN
                                                    AdditionalPostingCode := ECToPost."Extra Charge Code";
                                                    InitInvtPostBuffer(
                                                      ValueEntry,
                                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                                      GlobalInvtPostBuf."Account Type"::"Direct Cost Applied-EC",
                                                      ECToPost."Cost To Post", ECToPost."Cost To Post (ACY)", FALSE);
                                                    CostToPost -= ECToPost."Cost To Post";
                                                    CostToPostACY -= ECToPost."Cost To Post (ACY)";
                                                END;
                                            UNTIL ECToPost.NEXT = 0;
                                        IF (CostToPost <> 0) OR (CostToPostACY <> 0) THEN // P8001061
                                                                                          // P8000928
                                            InitInvtPostBuffer(
                    ValueEntry,
                    GlobalInvtPostBuf."Account Type"::Inventory,
                    GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                    CostToPost, CostToPostACY, FALSE); // PR4.00
                                    END; // P8000928
                                ItemLedgerEntry."Writeoff Responsibility ELA"::Company:
                                    InitInvtPostBuffer(
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                      GlobalInvtPostBuf."Account Type"::"Writeoff (Company)",
                                      CostToPost, CostToPostACY, FALSE); // PR4.00
                                ItemLedgerEntry."Writeoff Responsibility ELA"::Vendor:
                                    InitInvtPostBuffer(
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                      GlobalInvtPostBuf."Account Type"::"Writeoff (Vendor)",
                                      CostToPost, CostToPostACY, FALSE); // PR4.00
                            END;
                        END;
                        // PR3.61.01 End
                    END;
                "Entry Type"::Revaluation,
              "Entry Type"::Rounding:
                    InitInvtPostBuffer(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, FALSE);
                // P80050651
                "Entry Type"::"Indirect Cost":
                    IF "New Order Type ELA" = "New Order Type ELA"::Repack THEN
                        InitInvtPostBuffer(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::Inventory,
                          GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                          CostToPost, CostToPostACY, FALSE)
                    ELSE
                        ErrorNonValidCombination(ValueEntry);
                // P80050651
                // P8001195
                "Entry Type"::Variance:
                    IF "New Order Type ELA" IN ["New Order Type ELA"::Repack, "New Order Type ELA"::"Sales Repack"] THEN BEGIN
                        CASE "Variance Type" OF
                            "Variance Type"::Material:
                                InitInvtPostBuffer(
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Material Variance",
                                  CostToPost, CostToPostACY, FALSE);
                            "Variance Type"::Capacity:
                                InitInvtPostBuffer(
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Capacity Variance",
                                  CostToPost, CostToPostACY, FALSE);
                            "Variance Type"::Subcontracted:
                                InitInvtPostBuffer(
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Subcontracted Variance",
                                  CostToPost, CostToPostACY, FALSE);
                            "Variance Type"::"Capacity Overhead":
                                InitInvtPostBuffer(
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Cap. Overhead Variance",
                                  CostToPost, CostToPostACY, FALSE);
                            "Variance Type"::"Manufacturing Overhead":
                                InitInvtPostBuffer(
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Mfg. Overhead Variance",
                                  CostToPost, CostToPostACY, FALSE);
                            ELSE
                                ErrorNonValidCombination(ValueEntry);
                        END;
                    END ELSE
                        ErrorNonValidCombination(ValueEntry);
                // P8001195
                ELSE
                    ErrorNonValidCombination(ValueEntry);
            END;
    end;

    procedure InitInvtPostBuffer(ValueEntry: Record "Value Entry"; AccType: Enum "EN Posting Buffer Acc. Type"; BalAccType: Enum "EN Posting Buffer Acc. Type"; CostToPost: Decimal; CostToPostACY: Decimal; InterimAccount: Boolean)
    var
        InvtPostToGL: Codeunit "Inventory Posting To G/L";
    begin

        PostBufDimNo := PostBufDimNo + 1;
        CLEAR(TempInvtPostBuf);                                                        // P8000466A
        SetAccNo(TempInvtPostBuf, ValueEntry, AdditionalPostingCode, AccType, BalAccType); // P8000466A
        SetPostBufferAmounts(TempInvtPostBuf, CostToPost, CostToPostACY, InterimAccount);    // P8000466A
        TempInvtPostBuf."Dimension Set ID" := ValueEntry."Dimension Set ID"; // P8001133
        TempInvtPostBuf.INSERT;                                                        // P8000466A
        OnAfterInitTempInvtPostBuffer(TempInvtPostBuf, ValueEntry);

        PostBufDimNo := PostBufDimNo + 1;
        CLEAR(TempInvtPostBuf);                                                        // P8000466A
        SetAccNo(TempInvtPostBuf, ValueEntry, AdditionalPostingCode, BalAccType, AccType); // P8000466A
        SetPostBufferAmounts(TempInvtPostBuf, -CostToPost, -CostToPostACY, InterimAccount);  // P8000466A
        TempInvtPostBuf."Dimension Set ID" := ValueEntry."Dimension Set ID"; // P8001133
        TempInvtPostBuf.INSERT;                                                        // P8000466A
        OnAfterInitTempInvtPostBuffer(TempInvtPostBuf, ValueEntry);

        OnAfterInitInvtPostBuffer(ValueEntry);

        AdditionalPostingCode := ''; // P8000466A
    end;

    procedure SetPostBufferAmounts(VAR InvtPostBuf: Record "EN Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; InterimAccount: Boolean)
    begin
        InvtPostBuf."Interim Account" := InterimAccount;
        InvtPostBuf.Amount := CostToPost;
        InvtPostBuf."Amount (ACY)" := CostToPostACY;
    end;

    procedure ErrorNonValidCombination(ValueEntry: Record "Value Entry")
    begin
        IF CalledFromTestReport THEN
            InsertTempInvtPostToGLTestBuf2(ValueEntry)
        ELSE
            ;
        /*ERROR(
          Text002,
          FIELDCAPTION(ValueEntry."Item Ledger Entry Type"), ValueEntry."Item Ledger Entry Type",
          FIELDCAPTION(ValueEntry."Entry Type"), ValueEntry."Entry Type",
          FIELDCAPTION(ValueEntry."Expected Cost"), ValueEntry."Expected Cost");*/
    end;

    procedure InsertTempInvtPostToGLTestBuf2(ValueEntry: Record "Value Entry")
    begin
        TempInvtPostToGLTestBuf."Line No." := GetNextLineNo;
        TempInvtPostToGLTestBuf."Posting Date" := ValueEntry."Posting Date";
        TempInvtPostToGLTestBuf.Description := STRSUBSTNO(Text003, ValueEntry, ValueEntry."Entry No.");
        TempInvtPostToGLTestBuf.Amount := ValueEntry."Cost Amount (Actual)";
        TempInvtPostToGLTestBuf."Value Entry No." := ValueEntry."Entry No.";
        TempInvtPostToGLTestBuf."Dimension Set ID" := ValueEntry."Dimension Set ID";
        TempInvtPostToGLTestBuf.INSERT;
    end;

    procedure GetNextLineNo(): Integer
    var
        InvtPostToGLTestBuffer: Record "Invt. Post to G/L Test Buffer";
        LastLineNo: Integer;
    begin
        InvtPostToGLTestBuffer := TempInvtPostToGLTestBuf;
        IF TempInvtPostToGLTestBuf.FINDLAST THEN
            LastLineNo := TempInvtPostToGLTestBuf."Line No." + 10000
        ELSE
            LastLineNo := 10000;
        TempInvtPostToGLTestBuf := InvtPostToGLTestBuffer;
        EXIT(LastLineNo);
    end;

    procedure UpdateValueEntry(VAR ValueEntry: Record "Value Entry")
    begin
        WITH ValueEntry DO BEGIN
            IF GlobalInvtPostBuf."Interim Account" THEN BEGIN
                "Expected Cost Posted to G/L" := "Cost Amount (Expected)";
                "Exp. Cost Posted to G/L (ACY)" := "Cost Amount (Expected) (ACY)";
            END ELSE BEGIN
                "Cost Posted to G/L" := "Cost Amount (Actual)";
                "Cost Posted to G/L (ACY)" := "Cost Amount (Actual) (ACY)";
            END;
            IF NOT CalledFromItemPosting THEN
                MODIFY;
            // P8000466A
            //IF ProcessFns.FreshProInstalled THEN
              //  ExtraChargeMgmt.UpdatePostedCharge("Entry No.", GlobalInvtPostBuf."Interim Account");
            /* IF InvtSetup."ABC Detail Posting" AND (NOT GlobalInvtPostBuf."Interim Account") THEN BEGIN
                ValueEntryABCDetail.SETRANGE("Entry No.", "Entry No.");
                IF ValueEntryABCDetail.FINDSET(TRUE, FALSE) THEN
                    REPEAT
                        ValueEntryABCDetail."Cost Posted to G/L" := ValueEntryABCDetail.Cost;
                        ValueEntryABCDetail."Cost Posted to G/L (ACY)" := ValueEntryABCDetail."Cost (ACY)";
                        ValueEntryABCDetail."Overhead Posted to G/L" := ValueEntryABCDetail.Overhead;
                        ValueEntryABCDetail."Overhead Posted to G/L (ACY)" := ValueEntryABCDetail."Overhead (ACY)";
                        ValueEntryABCDetail.MODIFY;
                    UNTIL ValueEntryABCDetail.NEXT = 0; */
        END;
        // P8000466A
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterInitTempInvtPostBuffer(var TempIntPostBuf: Record "EN Invt. Posting Buffer" temporary; ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterInitInvtPostBuffer(var ValueEntry: Record "Value Entry")
    begin
    end;

    procedure UpdateExtraChargeSummary(PurchLine: Record "Purchase Line"; PurchInvLine: Record "Purch. Inv. Line")
    var
        ExtraChargeSummary: Record "EN Extra Charge Summary";
        PurchInvHead: Record "Purch. Inv. Header";
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        PurchInvLine2: Record "Purch. Inv. Line";
    begin
        //<<ENEC1.00
        IF (PurchLine."Purch. Ord for Ext Charge ELA" = '') OR (PurchLine."Extra Charge Code ELA" = '') THEN
            EXIT;

        IF ExtraChargeSummary.GET(PurchLine."Purch. Ord for Ext Charge ELA", PurchLine."Extra Charge Code ELA") THEN BEGIN
            ExtraChargeSummary."Posted Invoice Amount" += PurchInvLine."Line Amount";
            IF ExtraChargeSummary."Posted Invoice Amount" >= ExtraChargeSummary."Charge Amount" THEN
                ExtraChargeSummary.Open := FALSE;
            ExtraChargeSummary."Invoice No." := PurchInvLine."Document No.";
            IF PurchInvHead.GET(PurchInvLine."Document No.") THEN
                ExtraChargeSummary."Invoice Date" := PurchInvHead."Posting Date";

            ExtraChargeSummary.MODIFY;

            //<<EN 102718 Rpatel
            PstdDocExtraCharge.RESET;
            PstdDocExtraCharge.SETFILTER("Table ID", '%1|%2', 122, 123);
            PstdDocExtraCharge.SETFILTER("Document No.", '%1', PurchLine."Purch. Ord for Ext Charge ELA" + '*');
            PstdDocExtraCharge.SETRANGE("Extra Charge Code", PurchLine."Extra Charge Code ELA");
            IF PstdDocExtraCharge.FINDSET THEN
                REPEAT
                    PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Closed;
                    PstdDocExtraCharge."EC Invoice No." := PurchInvLine."Document No.";
                    PstdDocExtraCharge."EC Inv Posting Date" := PurchInvHead."Posting Date";
                    PstdDocExtraCharge.MODIFY;
                UNTIL PstdDocExtraCharge.NEXT = 0;

            IF PurchLine."Purch. Ord for Ext Charge ELA" = PurchLine."Document No." THEN BEGIN
                PstdDocExtraCharge.RESET;
                PstdDocExtraCharge.SETFILTER("Table ID", '%1|%2', 120, 121);
                PstdDocExtraCharge.SETFILTER("Document No.", '%1', PurchLine."Document No." + '*');
                PstdDocExtraCharge.SETFILTER(Status, '%1', PstdDocExtraCharge.Status::Interim);
                PstdDocExtraCharge.SETFILTER("Extra Charge Code", '<>%1', PurchLine."Extra Charge Code ELA");
                IF PstdDocExtraCharge.FINDSET THEN
                    REPEAT
                        PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Open;
                        PstdDocExtraCharge.MODIFY;
                    UNTIL PstdDocExtraCharge.NEXT = 0;
            END;

            PstdDocExtraCharge.RESET;
            PstdDocExtraCharge.SETFILTER("Table ID", '%1|%2|%3|%4', 120, 121, 122, 123);
            PstdDocExtraCharge.SETFILTER("Document No.", '%1', PurchLine."Purch. Ord for Ext Charge ELA" + '*');
            PstdDocExtraCharge.SETFILTER(Status, '<>%1', PstdDocExtraCharge.Status::Closed);
            IF PstdDocExtraCharge.FINDSET THEN
                REPEAT
                    PurchInvLine2.RESET;
                    PurchInvLine2.SETRANGE("Extra Charge Code ELA", PstdDocExtraCharge."Extra Charge Code");
                    PurchInvLine2.SETFILTER("Purch. Ord for Extra Chrg ELA", '%1', PurchLine."Purch. Ord for Ext Charge ELA" + '*');
                    IF PurchInvLine2.FINDFIRST THEN BEGIN
                        PurchInvHead.GET(PurchInvLine2."Document No.");
                        PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Closed;
                        IF PstdDocExtraCharge."Table ID" IN [122, 123] THEN BEGIN
                            PstdDocExtraCharge."EC Invoice No." := PurchInvLine2."Document No.";
                            PstdDocExtraCharge."EC Inv Posting Date" := PurchInvHead."Posting Date"
                        END;
                        PstdDocExtraCharge.MODIFY;
                    END;
                UNTIL PstdDocExtraCharge.NEXT = 0;
            //>>EN 102718
        END;
        //>>ENEC1.00
    end;
    
    var
        
        ExtraChargeMgmt: Codeunit "EN Extra Charge Management";
        RecalculateLines: Boolean;
        PurchDocType: Enum "EN Purchase Doc. Type";
        CalledFromItemPosting: Boolean;
        CalledFromTestReport: Boolean;
        AdditionalPostingCode: Code[20];
        GlobalInvtPostBuf: Record "EN Invt. Posting Buffer";
        PostBufDimNo: Integer;
        TempInvtPostBuf: Record "EN Invt. Posting Buffer" temporary;
        TempInvtPostToGLTestBuf: Record "Invt. Post to G/L Test Buffer";
        Text003: TextConst ENU = '%1 %2';
        Text002: TextConst ENU = 'The following combination %1 = %2, %3 = %4, and %5 = %6 is not allowed.';
        ExtraCharge: Boolean;
}