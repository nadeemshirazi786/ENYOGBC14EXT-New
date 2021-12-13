codeunit 14229103 "EN Inventory Posting To G/L"
{
   
    Permissions = TableData "G/L Account" = r,
                  TableData "EN Invt. Posting Buffer" = rimd,
                  TableData "Value Entry" = rm,
                  TableData "G/L - Item Ledger Relation" = rimd;
    TableNo = "Value Entry";

    trigger OnRun()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if GlobalPostPerPostGroup then
            PostInvtPostBuf(Rec, "Document No.", '', '', true)
        else
            PostInvtPostBuf(
              Rec,
              "Document No.",
              "External Document No.",
              CopyStr(
                StrSubstNo(Text000, "Entry Type", "Source No.", "Posting Date"),
                1, MaxStrLen(GenJnlLine.Description)),
              false);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        InvtSetup: Record "Inventory Setup";
        Currency: Record Currency;
        SourceCodeSetup: Record "Source Code Setup";
        GlobalInvtPostBuf: Record "EN Invt. Posting Buffer" temporary;
        TempInvtPostBuf: Record "EN Invt. Posting Buffer" temporary;
        TempInvtPostToGLTestBuf: Record "Invt. Post to G/L Test Buffer" temporary;
        TempGLItemLedgRelation: Record "G/L - Item Ledger Relation" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        DimMgt: Codeunit DimensionManagement;
        COGSAmt: Decimal;
        InvtAdjmtAmt: Decimal;
        DirCostAmt: Decimal;
        OvhdCostAmt: Decimal;
        VarPurchCostAmt: Decimal;
        VarMfgDirCostAmt: Decimal;
        VarMfgOvhdCostAmt: Decimal;
        WIPInvtAmt: Decimal;
        InvtAmt: Decimal;
        TotalCOGSAmt: Decimal;
        TotalInvtAdjmtAmt: Decimal;
        TotalDirCostAmt: Decimal;
        TotalOvhdCostAmt: Decimal;
        TotalVarPurchCostAmt: Decimal;
        TotalVarMfgDirCostAmt: Decimal;
        TotalVarMfgOvhdCostAmt: Decimal;
        TotalWIPInvtAmt: Decimal;
        TotalInvtAmt: Decimal;
        GlobalInvtPostBufEntryNo: Integer;
        PostBufDimNo: Integer;
        GLSetupRead: Boolean;
        SourceCodeSetupRead: Boolean;
        InvtSetupRead: Boolean;
        Text000: Label '%1 %2 on %3';
        Text001: Label '%1 - %2, %3,%4,%5,%6';
        Text002: Label 'The following combination %1 = %2, %3 = %4, and %5 = %6 is not allowed.';
        RunOnlyCheck: Boolean;
        RunOnlyCheckSaved: Boolean;
        CalledFromItemPosting: Boolean;
        CalledFromTestReport: Boolean;
        GlobalPostPerPostGroup: Boolean;
        Text003: Label '%1 %2';
        //ProcessFns: Codeunit "Process 800 Functions"; ///EN
        ExtraChargeMgmt: Codeunit "EN Extra Charge Management";
        //ValueEntryABCDetail: Record "Value Entry ABC Detail"; ///EN
        AdditionalPostingCode: Code[20];

    procedure Initialize(PostPerPostGroup: Boolean)
    begin
        GlobalPostPerPostGroup := PostPerPostGroup;
        GlobalInvtPostBufEntryNo := 0;
    end;

    procedure SetRunOnlyCheck(SetCalledFromItemPosting: Boolean; SetCheckOnly: Boolean; SetCalledFromTestReport: Boolean)
    begin
        CalledFromItemPosting := SetCalledFromItemPosting;
        RunOnlyCheck := SetCheckOnly;
        CalledFromTestReport := SetCalledFromTestReport;

        TempGLItemLedgRelation.Reset;
        TempGLItemLedgRelation.DeleteAll;
    end;

    procedure BufferInvtPosting(var ValueEntry: Record "Value Entry"): Boolean
    var
        CostToPost: Decimal;
        CostToPostACY: Decimal;
        ExpCostToPost: Decimal;
        ExpCostToPostACY: Decimal;
        PostToGL: Boolean;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ECToPost: Record "EN Extra Charge Posting Buffer" temporary;
        PostABCDetail: Boolean;
        ABCCostToPost: Decimal;
        ABCCostToPostACY: Decimal;
        PostABCToGL: Boolean;
    begin
        with ValueEntry do begin
            GetGLSetup;
            GetInvtSetup;
            if (not InvtSetup."Expected Cost Posting to G/L") and
               ("Expected Cost Posted to G/L" = 0) and
               "Expected Cost"
            then
                exit(false);

            if not ("Entry Type" in ["Entry Type"::"Direct Cost", "Entry Type"::Revaluation]) and
               not CalledFromTestReport
            then begin
                TestField("Expected Cost", false);
                TestField("Cost Amount (Expected)", 0);
                TestField("Cost Amount (Expected) (ACY)", 0);
            end;

            if InvtSetup."Expected Cost Posting to G/L" then begin
                CalcCostToPost(ExpCostToPost, "Cost Amount (Expected)", "Expected Cost Posted to G/L", PostToGL);
                CalcCostToPost(ExpCostToPostACY, "Cost Amount (Expected) (ACY)", "Exp. Cost Posted to G/L (ACY)", PostToGL);
                ExtraChargeMgmt.CalcChargeToPost(ECToPost, "Entry No.", true, PostToGL); // PR4.00
            end;
            CalcCostToPost(CostToPost, "Cost Amount (Actual)", "Cost Posted to G/L", PostToGL);
            CalcCostToPost(CostToPostACY, "Cost Amount (Actual) (ACY)", "Cost Posted to G/L (ACY)", PostToGL);
            ExtraChargeMgmt.CalcChargeToPost(ECToPost, "Entry No.", false, PostToGL); // PR4.00
            OnAfterCalcCostToPostFromBuffer(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY);
            PostBufDimNo := 0;

            RunOnlyCheckSaved := RunOnlyCheck;
            if not PostToGL then
                exit(false);

            case "Item Ledger Entry Type" of
                "Item Ledger Entry Type"::Purchase:
                    BufferPurchPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY, ECToPost); // P8001132
                "Item Ledger Entry Type"::Sale:
                    BufferSalesPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY);
                "Item Ledger Entry Type"::"Positive Adjmt.",
              "Item Ledger Entry Type"::"Negative Adjmt.",
              "Item Ledger Entry Type"::Transfer:
                    BufferAdjmtPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY, ECToPost); // P8001132
                "Item Ledger Entry Type"::Consumption:
                    BufferConsumpPosting(ValueEntry, CostToPost, CostToPostACY);
                "Item Ledger Entry Type"::Output:
                    BufferOutputPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY);
                "Item Ledger Entry Type"::"Assembly Consumption":
                    BufferAsmConsumpPosting(ValueEntry, CostToPost, CostToPostACY);
                "Item Ledger Entry Type"::"Assembly Output":
                    BufferAsmOutputPosting(ValueEntry, CostToPost, CostToPostACY);
                "Item Ledger Entry Type"::" ":
                    BufferCapPosting(ValueEntry, CostToPost, CostToPostACY);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
        end;

        if UpdateGlobalInvtPostBuf(ValueEntry."Entry No.") then
            exit(true);
        exit(CalledFromTestReport);
    end;

    local procedure BufferPurchPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var ECToPost: Record "EN Extra Charge Posting Buffer" temporary)
    begin
        // P8001132 - add parameter for ECToPost
        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    begin
                        // PR4.00 Begin
                        if ECToPost.Find('-') then
                            repeat
                                if (ECToPost."Cost To Post (Expected)" <> 0) or (ECToPost."Cost To Post (Expected) (ACY)" <> 0) then begin
                                    // P8000466A
                                    //UpdateInvtPostBufEC(
                                    AdditionalPostingCode := ECToPost."Extra Charge Code";
                                    InitInvtPostBuf(
                                      // P8000466A
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                                      GlobalInvtPostBuf."Account Type"::"Invt. Accrual-EC (Interim)",
                                      //ECToPost."Extra Charge Code", // P8000466A
                                      ECToPost."Cost To Post (Expected)", ECToPost."Cost To Post (Expected) (ACY)", true);
                                    ExpCostToPost -= ECToPost."Cost To Post (Expected)";
                                    ExpCostToPostACY -= ECToPost."Cost To Post (Expected) (ACY)";
                                end;
                                if (ECToPost."Cost To Post" <> 0) or (ECToPost."Cost To Post (ACY)" <> 0) then begin
                                    // P8000466A
                                    //UpdateInvtPostBufEC(
                                    AdditionalPostingCode := ECToPost."Extra Charge Code";
                                    InitInvtPostBuf(
                                      // P8000466A
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                      GlobalInvtPostBuf."Account Type"::"Direct Cost Applied-EC",
                                      //ECToPost."Extra Charge Code", // P8000466A
                                      ECToPost."Cost To Post", ECToPost."Cost To Post (ACY)", false);
                                    CostToPost -= ECToPost."Cost To Post";
                                    CostToPostACY -= ECToPost."Cost To Post (ACY)";
                                end;
                            until ECToPost.Next = 0;
                        // PR4.00 End
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"Invt. Accrual (Interim)",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Direct Cost Applied",
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::"Indirect Cost":
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::Variance:
                    begin
                        TestField("Variance Type", "Variance Type"::Purchase);
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::Inventory,
                          GlobalInvtPostBuf."Account Type"::"Purchase Variance",
                          CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::Revaluation:
                    begin
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"Invt. Accrual (Interim)",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
    end;

    local procedure BufferSalesPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal)
    begin
        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    begin
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"COGS (Interim)",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::COGS,
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::Revaluation:
                    begin
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"COGS (Interim)",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;

        OnAfterBufferSalesPosting(TempInvtPostBuf, ValueEntry, PostBufDimNo);
    end;

    local procedure BufferOutputPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal)
    var
        PostABCDetail: Boolean;
        PostABCToGL: Boolean;
        ABCCostToPost: Decimal;
        ABCCostToPostACY: Decimal;
    begin
        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    begin
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::"Indirect Cost":
                    
                    begin
                        
                    InitInvtPostBuf(
                        ValueEntry,
                        GlobalInvtPostBuf."Account Type"::Inventory,
                        GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                        CostToPost, CostToPostACY, false);
                    end; 
                "Entry Type"::Variance:
                    case "Variance Type" of
                        "Variance Type"::Material:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Material Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::Capacity:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Capacity Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::Subcontracted:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Subcontracted Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::"Capacity Overhead":
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Cap. Overhead Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::"Manufacturing Overhead":
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Mfg. Overhead Variance",
                              CostToPost, CostToPostACY, false);
                        else
                            ErrorNonValidCombination(ValueEntry);
                    end;
                "Entry Type"::Revaluation:
                    begin
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
    end;

    local procedure BufferConsumpPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal)
    begin
        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::Revaluation,
              "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
    end;

    local procedure BufferCapPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal)
    begin
        with ValueEntry do
            if "Order Type" = "Order Type"::Assembly then
                case "Entry Type" of
                    "Entry Type"::"Direct Cost":
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                          GlobalInvtPostBuf."Account Type"::"Direct Cost Applied",
                          CostToPost, CostToPostACY, false);
                    "Entry Type"::"Indirect Cost":
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                          GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                          CostToPost, CostToPostACY, false);
                    else
                        ErrorNonValidCombination(ValueEntry);
                end
            else
                case "Entry Type" of
                    "Entry Type"::"Direct Cost":
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                          GlobalInvtPostBuf."Account Type"::"Direct Cost Applied",
                          CostToPost, CostToPostACY, false);
                    "Entry Type"::"Indirect Cost":
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                          GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                          CostToPost, CostToPostACY, false);
                    else
                        ErrorNonValidCombination(ValueEntry);
                end;
    end;

    local procedure BufferAsmOutputPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal)
    begin
        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::"Indirect Cost":
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::Variance:
                    case "Variance Type" of
                        "Variance Type"::Material:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Material Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::Capacity:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Capacity Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::Subcontracted:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Subcontracted Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::"Capacity Overhead":
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Cap. Overhead Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::"Manufacturing Overhead":
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Mfg. Overhead Variance",
                              CostToPost, CostToPostACY, false);
                        else
                            ErrorNonValidCombination(ValueEntry);
                    end;
                "Entry Type"::Revaluation:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
    end;

    local procedure BufferAsmConsumpPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal)
    begin
        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::Revaluation,
              "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
    end;

    local procedure BufferAdjmtPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var ECToPost: Record "EN Extra Charge Posting Buffer" temporary)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // P8001132 - add parameter for ECToPost
        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    begin
                        // Posting adjustments to Interim accounts (Service)
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"COGS (Interim)",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                        // PR3.61.01 Begin
                        //  InitInvtPostBuf(
                        //    ValueEntry,
                        //    GlobalInvtPostBuf."Account Type"::Inventory,
                        //    GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                        //    CostToPost,CostToPostACY,FALSE);
                        begin
                            ItemLedgerEntry.Get("Item Ledger Entry No.");
                            case ItemLedgerEntry."Writeoff Responsibility ELA" of
                                ItemLedgerEntry."Writeoff Responsibility ELA"::" ":
                                    // P8000928
                                    begin
                                        if ECToPost.Find('-') then
                                            repeat
                                                if (ECToPost."Cost To Post" <> 0) or (ECToPost."Cost To Post (ACY)" <> 0) then begin
                                                    AdditionalPostingCode := ECToPost."Extra Charge Code";
                                                    InitInvtPostBuf(
                                                      ValueEntry,
                                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                                      GlobalInvtPostBuf."Account Type"::"Direct Cost Applied-EC",
                                                      ECToPost."Cost To Post", ECToPost."Cost To Post (ACY)", false);
                                                    CostToPost -= ECToPost."Cost To Post";
                                                    CostToPostACY -= ECToPost."Cost To Post (ACY)";
                                                end;
                                            until ECToPost.Next = 0;
                                        if (CostToPost <> 0) or (CostToPostACY <> 0) then // P8001061
                                                                                          // P8000928
                                            InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::Inventory,
                            GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                            CostToPost, CostToPostACY, false); // PR4.00
                                    end; // P8000928
                                ItemLedgerEntry."Writeoff Responsibility ELA"::Company:
                                    InitInvtPostBuf(
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                      GlobalInvtPostBuf."Account Type"::"Writeoff (Company)",
                                      CostToPost, CostToPostACY, false); // PR4.00
                                ItemLedgerEntry."Writeoff Responsibility ELA"::Vendor:
                                    InitInvtPostBuf(
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                      GlobalInvtPostBuf."Account Type"::"Writeoff (Vendor)",
                                      CostToPost, CostToPostACY, false); // PR4.00
                            end;
                        end;
                        // PR3.61.01 End
                    end;
                "Entry Type"::Revaluation,
              "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetup.Get;
            if GLSetup."Additional Reporting Currency" <> '' then
                Currency.Get(GLSetup."Additional Reporting Currency");
        end;
        GLSetupRead := true;
    end;

    local procedure GetInvtSetup()
    begin
        if not InvtSetupRead then
            InvtSetup.Get;
        InvtSetupRead := true;
    end;

    local procedure CalcCostToPost(var CostToPost: Decimal; AdjdCost: Decimal; var PostedCost: Decimal; var PostToGL: Boolean)
    begin
        CostToPost := AdjdCost - PostedCost;

        if CostToPost <> 0 then begin
            if not RunOnlyCheck then
                PostedCost := AdjdCost;
            PostToGL := true;
        end;
    end;

    local procedure InitInvtPostBuf(ValueEntry: Record "Value Entry"; AccType: Option; BalAccType: Option; CostToPost: Decimal; CostToPostACY: Decimal; InterimAccount: Boolean)
    begin
        

        PostBufDimNo := PostBufDimNo + 1;
        Clear(TempInvtPostBuf);                                                        // P8000466A
        SetAccNo(TempInvtPostBuf, ValueEntry, AdditionalPostingCode, AccType, BalAccType); // P8000466A
        SetPostBufAmounts(TempInvtPostBuf, CostToPost, CostToPostACY, InterimAccount);    // P8000466A
        TempInvtPostBuf."Dimension Set ID" := ValueEntry."Dimension Set ID"; // P8001133
        TempInvtPostBuf.Insert;                                                        // P8000466A
        

        PostBufDimNo := PostBufDimNo + 1;
        Clear(TempInvtPostBuf);                                                        // P8000466A
        SetAccNo(TempInvtPostBuf, ValueEntry, AdditionalPostingCode, BalAccType, AccType); // P8000466A
        SetPostBufAmounts(TempInvtPostBuf, -CostToPost, -CostToPostACY, InterimAccount);  // P8000466A
        TempInvtPostBuf."Dimension Set ID" := ValueEntry."Dimension Set ID"; // P8001133
        TempInvtPostBuf.Insert;                                                        // P8000466A
        

        

        AdditionalPostingCode := ''; // P8000466A
    end;

    local procedure SetAccNo(var InvtPostBuf: Record "EN Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; AdditionalPostingCode: Code[20]; AccType: Option; BalAccType: Option)
    var
        InvtPostSetup: Record "Inventory Posting Setup";
        GenPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        ECPostingSetup: Record "EN Extra Charge Posting Setup";
        Resource: Record Resource;
    begin
        // P8000466A - parameter added for additional posting code
        with InvtPostBuf do begin
            "Account No." := '';
            "Account Type" := AccType;
            "Bal. Account Type" := BalAccType;
            "Location Code" := ValueEntry."Location Code";
            "Inventory Posting Group" :=
              GetInvPostingGroupCode(ValueEntry, AccType = "Account Type"::"WIP Inventory", ValueEntry."Inventory Posting Group");
            "Gen. Bus. Posting Group" := ValueEntry."Gen. Bus. Posting Group";
            // P8000466A
            if UseABCDetail then begin
                Resource.Get(AdditionalPostingCode);
                "Gen. Prod. Posting Group" := Resource."Gen. Prod. Posting Group"
            end else
                // P8000466A
                "Gen. Prod. Posting Group" := ValueEntry."Gen. Prod. Posting Group";
            "Posting Date" := ValueEntry."Posting Date";
            "Additional Posting Code" := AdditionalPostingCode; // P8000466A

            // P8000062B
            if UseECPostingSetup then begin // P8000466A
                if CalledFromItemPosting then
                    ECPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Additional Posting Code") // P8000466A
                else
                    if not ECPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Additional Posting Code") then // P8000466A
                        exit;
                // P8000062B
            end else
                if UseInvtPostSetup then begin // P8000062B
                    if CalledFromItemPosting then
                        InvtPostSetup.Get("Location Code", "Inventory Posting Group")
                    else
                        if not InvtPostSetup.Get("Location Code", "Inventory Posting Group") then
                            exit;
                end else begin
                    if CalledFromItemPosting then
                        GenPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group")
                    else
                        if not GenPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group") then
                            exit;
                end;

            case "Account Type" of
                "Account Type"::Inventory:
                    if CalledFromItemPosting then
                        "Account No." := InvtPostSetup.GetInventoryAccount
                    else
                        "Account No." := InvtPostSetup."Inventory Account";
                "Account Type"::"Inventory (Interim)":
                    if CalledFromItemPosting then
                        "Account No." := InvtPostSetup.GetInventoryAccountInterim
                    else
                        "Account No." := InvtPostSetup."Inventory Account (Interim)";
                "Account Type"::"WIP Inventory":
                    if CalledFromItemPosting then
                        "Account No." := InvtPostSetup.GetWIPAccount
                    else
                        "Account No." := InvtPostSetup."WIP Account";
                "Account Type"::"Material Variance":
                    if CalledFromItemPosting then
                        "Account No." := InvtPostSetup.GetMaterialVarianceAccount
                    else
                        "Account No." := InvtPostSetup."Material Variance Account";
                "Account Type"::"Capacity Variance":
                    if CalledFromItemPosting then
                        "Account No." := InvtPostSetup.GetCapacityVarianceAccount
                    else
                        "Account No." := InvtPostSetup."Capacity Variance Account";
                "Account Type"::"Subcontracted Variance":
                    if CalledFromItemPosting then
                        "Account No." := InvtPostSetup.GetSubcontractedVarianceAccount
                    else
                        "Account No." := InvtPostSetup."Subcontracted Variance Account";
                "Account Type"::"Cap. Overhead Variance":
                    if CalledFromItemPosting then
                        "Account No." := InvtPostSetup.GetCapOverheadVarianceAccount
                    else
                        "Account No." := InvtPostSetup."Cap. Overhead Variance Account";
                "Account Type"::"Mfg. Overhead Variance":
                    if CalledFromItemPosting then
                        "Account No." := InvtPostSetup.GetMfgOverheadVarianceAccount
                    else
                        "Account No." := InvtPostSetup."Mfg. Overhead Variance Account";
                "Account Type"::"Inventory Adjmt.":
                    if CalledFromItemPosting then
                        "Account No." := GenPostingSetup.GetInventoryAdjmtAccount
                    else
                        "Account No." := GenPostingSetup."Inventory Adjmt. Account";
                "Account Type"::"Direct Cost Applied":
                    if CalledFromItemPosting then
                        "Account No." := GenPostingSetup.GetDirectCostAppliedAccount
                    else
                        "Account No." := GenPostingSetup."Direct Cost Applied Account";
                "Account Type"::"Overhead Applied":
                    if CalledFromItemPosting then
                        "Account No." := GenPostingSetup.GetOverheadAppliedAccount
                    else
                        "Account No." := GenPostingSetup."Overhead Applied Account";
                /* ///EN Begin
                // P8000375A
                "Account Type"::"ABC Direct":
                    if CalledFromItemPosting then
                        "Account No." := GenPostingSetup.GetABCDirectAccount // P80053245
                    else
                        "Account No." := GenPostingSetup."ABC Direct Account";
                "Account Type"::"ABC Overhead":
                    if CalledFromItemPosting then
                        "Account No." := GenPostingSetup.GetABCOverheadAccount // P80053245
                    else
                        "Account No." := GenPostingSetup."ABC Overhead Account";
                // P8000375A
                */ ///EN End
                "Account Type"::"Purchase Variance":
                    if CalledFromItemPosting then
                        "Account No." := GenPostingSetup.GetPurchaseVarianceAccount
                    else
                        "Account No." := GenPostingSetup."Purchase Variance Account";
                "Account Type"::COGS:
                    if CalledFromItemPosting then
                        "Account No." := GenPostingSetup.GetCOGSAccount
                    else
                        "Account No." := GenPostingSetup."COGS Account";
                "Account Type"::"COGS (Interim)":
                    if CalledFromItemPosting then
                        "Account No." := GenPostingSetup.GetCOGSInterimAccount
                    else
                        "Account No." := GenPostingSetup."COGS Account (Interim)";
                "Account Type"::"Invt. Accrual (Interim)":
                    if CalledFromItemPosting then
                        "Account No." := GenPostingSetup.GetInventoryAccrualAccount
                    else
                        "Account No." := GenPostingSetup."Invt. Accrual Acc. (Interim)";
                // PR3.61.01 Begin
                "Account Type"::"Writeoff (Company)":
                    if CalledFromItemPosting then
                        "Account No." := InvtPostSetup.GetWriteoffAccountCompanyELA // P80053245
                    else
                        "Account No." := InvtPostSetup."Writeoff Account (Company) ELA";
                "Account Type"::"Writeoff (Vendor)":
                    if CalledFromItemPosting then
                        "Account No." := InvtPostSetup.GetWriteoffAccountVendorELA // P80053245
                    else
                        "Account No." := InvtPostSetup."Writeoff Account (Vendor) ELA";
                // PR3.61.01 End
                // P8000062B Begin
                "Account Type"::"Invt. Accrual-EC (Interim)":
                    if CalledFromItemPosting then
                        "Account No." := ECPostingSetup.GetInventoryAccrualAccount // P80053245
                    else
                        "Account No." := ECPostingSetup."Invt. Accrual Acc. (Interim)";
                "Account Type"::"Direct Cost Applied-EC":
                    if CalledFromItemPosting then
                        "Account No." := ECPostingSetup.GetDirectCostAppliedAccount // P80053245
                    else
                        "Account No." := ECPostingSetup."Direct Cost Applied Account";
                    // P8000062B End
            end;
            if "Account No." <> '' then begin
                GLAccount.Get("Account No.");
                if GLAccount.Blocked then begin
                    if CalledFromItemPosting then
                        GLAccount.TestField(Blocked, false);
                    if not CalledFromTestReport then
                        "Account No." := '';
                end;
            end;
            
        end;
    end;

    local procedure SetPostBufAmounts(var InvtPostBuf: Record "EN Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; InterimAccount: Boolean)
    begin
        with InvtPostBuf do begin
            "Interim Account" := InterimAccount;
            Amount := CostToPost;
            "Amount (ACY)" := CostToPostACY;
        end;
    end;

    local procedure UpdateGlobalInvtPostBuf(ValueEntryNo: Integer): Boolean
    var
        i: Integer;
    begin
        with GlobalInvtPostBuf do begin
            if not CalledFromTestReport then
                /*P8000466A
                FOR i := 1 TO PostBufDimNo DO
                  IF TempInvtPostBuf[i]."Account No." = '' THEN BEGIN
                    CLEAR(TempInvtPostBuf);
                    EXIT(FALSE);
                  END;
                P8000466A*/
                // P8000466A
                if TempInvtPostBuf.Find('-') then
                    repeat
                        if TempInvtPostBuf."Account No." = '' then begin
                            TempInvtPostBuf.DeleteAll;
                            exit(false);
                        end;
                    until TempInvtPostBuf.Next = 0;
            // P8000466A
            //FOR i := 1 TO PostBufDimNo DO BEGIN // P8000466A
            if TempInvtPostBuf.Find('-') then     // P8000466A
                repeat                                // P8000466A
                    GlobalInvtPostBuf := TempInvtPostBuf; // P8000466A
                                                          //"Dimension Set ID" := TempInvtPostBuf[i]."Dimension Set ID"; // P8001133
                    Negative := (TempInvtPostBuf.Amount < 0) or (TempInvtPostBuf."Amount (ACY)" < 0); // P8000466A

                    UpdateReportAmounts;
                    // P8000466A
                    if not UseECPostingSetup then
                        "Additional Posting Code" := '';
                    if (not GlobalPostPerPostGroup) and (not UseABCDetail) then
                        "Bal. Account Type" := 0;
                    // P8000466A
                    if Find then begin
                        Amount := Amount + TempInvtPostBuf.Amount; // P8000466A
                        "Amount (ACY)" := "Amount (ACY)" + TempInvtPostBuf."Amount (ACY)"; // P8000466A
                        Modify;
                    end else begin
                        GlobalInvtPostBufEntryNo := GlobalInvtPostBufEntryNo + 1;
                        "Entry No." := GlobalInvtPostBufEntryNo;
                        Insert;
                    end;

                    if not (RunOnlyCheck or CalledFromTestReport) then begin
                        TempGLItemLedgRelation.Init;
                        TempGLItemLedgRelation."G/L Entry No." := "Entry No.";
                        TempGLItemLedgRelation."Value Entry No." := ValueEntryNo;
                        if TempGLItemLedgRelation.Insert then; // P8000466A
                    end;
                until TempInvtPostBuf.Next = 0; // P8000466A
                                                //END;                          // P8000466A
        end;
        //CLEAR(TempInvtPostBuf);
        TempInvtPostBuf.DeleteAll; // P8000466A
        exit(true);

    end;

    local procedure UpdateReportAmounts()
    begin
        with GlobalInvtPostBuf do
            case "Account Type" of
                "Account Type"::Inventory, "Account Type"::"Inventory (Interim)":
                    InvtAmt += Amount;
                "Account Type"::"WIP Inventory":
                    WIPInvtAmt += Amount;
                "Account Type"::"Writeoff (Company)", // PR3.61.01
              "Account Type"::"Writeoff (Vendor)",  // PR3.61.01
              "Account Type"::"Inventory Adjmt.":
                    InvtAdjmtAmt += Amount;
                "Account Type"::"Invt. Accrual-EC (Interim)", // P8000062B
              "Account Type"::"Invt. Accrual (Interim)":
                    InvtAdjmtAmt += Amount;
                "Account Type"::"Direct Cost Applied-EC",     // P8000062B
              "Account Type"::"Direct Cost Applied":
                    DirCostAmt += Amount;
                "Account Type"::"ABC Direct",   // P8000375A
              "Account Type"::"ABC Overhead", // P8000375A
              "Account Type"::"Overhead Applied":
                    OvhdCostAmt += Amount;
                "Account Type"::"Purchase Variance":
                    VarPurchCostAmt += Amount;
                "Account Type"::COGS:
                    COGSAmt += Amount;
                "Account Type"::"COGS (Interim)":
                    COGSAmt += Amount;
                "Account Type"::"Material Variance", "Account Type"::"Capacity Variance",
              "Account Type"::"Subcontracted Variance", "Account Type"::"Cap. Overhead Variance":
                    VarMfgDirCostAmt += Amount;
                "Account Type"::"Mfg. Overhead Variance":
                    VarMfgOvhdCostAmt += Amount;
            end;
    end;

    local procedure ErrorNonValidCombination(ValueEntry: Record "Value Entry")
    begin
        with ValueEntry do
            if CalledFromTestReport then
                InsertTempInvtPostToGLTestBuf2(ValueEntry)
            else
                Error(
                  Text002,
                  FieldCaption("Item Ledger Entry Type"), "Item Ledger Entry Type",
                  FieldCaption("Entry Type"), "Entry Type",
                  FieldCaption("Expected Cost"), "Expected Cost")
    end;

    local procedure InsertTempInvtPostToGLTestBuf2(ValueEntry: Record "Value Entry")
    begin
        with ValueEntry do begin
            TempInvtPostToGLTestBuf."Line No." := GetNextLineNo;
            TempInvtPostToGLTestBuf."Posting Date" := "Posting Date";
            TempInvtPostToGLTestBuf.Description := StrSubstNo(Text003, TableCaption, "Entry No.");
            TempInvtPostToGLTestBuf.Amount := "Cost Amount (Actual)";
            TempInvtPostToGLTestBuf."Value Entry No." := "Entry No.";
            TempInvtPostToGLTestBuf."Dimension Set ID" := "Dimension Set ID";
            TempInvtPostToGLTestBuf.Insert;
        end;
    end;

    local procedure GetNextLineNo(): Integer
    var
        InvtPostToGLTestBuffer: Record "Invt. Post to G/L Test Buffer";
        LastLineNo: Integer;
    begin
        InvtPostToGLTestBuffer := TempInvtPostToGLTestBuf;
        if TempInvtPostToGLTestBuf.FindLast then
            LastLineNo := TempInvtPostToGLTestBuf."Line No." + 10000
        else
            LastLineNo := 10000;
        TempInvtPostToGLTestBuf := InvtPostToGLTestBuffer;
        exit(LastLineNo);
    end;

    procedure PostInvtPostBufPerEntry(var ValueEntry: Record "Value Entry")
    var
        DummyGenJnlLine: Record "Gen. Journal Line";
    begin
        with ValueEntry do
            PostInvtPostBuf(
              ValueEntry,
              "Document No.",
              "External Document No.",
              CopyStr(
                StrSubstNo(Text000, "Entry Type", "Source No.", "Posting Date"),
                1, MaxStrLen(DummyGenJnlLine.Description)),
              false);
    end;

    procedure PostInvtPostBufPerPostGrp(DocNo: Code[20]; Desc: Text[50])
    var
        ValueEntry: Record "Value Entry";
    begin
        PostInvtPostBuf(ValueEntry, DocNo, '', Desc, true);
    end;

    local procedure PostInvtPostBuf(var ValueEntry: Record "Value Entry"; DocNo: Code[20]; ExternalDocNo: Code[35]; Desc: Text[50]; PostPerPostGrp: Boolean)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        with GlobalInvtPostBuf do begin
            Reset;
            
            if not FindSet then
                exit;

            GenJnlLine.Init;
            GenJnlLine."Document No." := DocNo;
            GenJnlLine."External Document No." := ExternalDocNo;
            GenJnlLine.Description := Desc;
            GetSourceCodeSetup;
            GenJnlLine."Source Code" := SourceCodeSetup."Inventory Post Cost";
            GenJnlLine."System-Created Entry" := true;
            GenJnlLine."Job No." := ValueEntry."Job No.";
            GenJnlLine."Reason Code" := ValueEntry."Reason Code";
            repeat
                GenJnlLine.Validate("Posting Date", "Posting Date");
                if SetAmt(GenJnlLine, Amount, "Amount (ACY)") then begin
                    if PostPerPostGrp then
                        SetDesc(GenJnlLine, GlobalInvtPostBuf);
                    GenJnlLine."Account No." := "Account No.";
                    GenJnlLine."Dimension Set ID" := "Dimension Set ID";
                    DimMgt.UpdateGlobalDimFromDimSetID(
                      "Dimension Set ID", GenJnlLine."Shortcut Dimension 1 Code",
                      GenJnlLine."Shortcut Dimension 2 Code");
                    if not CalledFromTestReport then
                        if not RunOnlyCheck then begin
                            if not CalledFromItemPosting then
                                GenJnlPostLine.SetOverDimErr;
                            OnBeforePostInvtPostBuf(GenJnlLine, GlobalInvtPostBuf, ValueEntry, GenJnlPostLine);
                            GenJnlPostLine.RunWithCheck(GenJnlLine)
                        end else
                            GenJnlCheckLine.RunCheck(GenJnlLine)
                    else
                        InsertTempInvtPostToGLTestBuf(GenJnlLine, ValueEntry);
                end;
                if not CalledFromTestReport and not RunOnlyCheck then
                    CreateGLItemLedgRelation(ValueEntry);
            until Next = 0;
            RunOnlyCheck := RunOnlyCheckSaved;
            DeleteAll;
        end;
    end;

    local procedure GetSourceCodeSetup()
    begin
        if not SourceCodeSetupRead then
            SourceCodeSetup.Get;
        SourceCodeSetupRead := true;
    end;

    local procedure SetAmt(var GenJnlLine: Record "Gen. Journal Line"; Amt: Decimal; AmtACY: Decimal): Boolean
    begin
        with GenJnlLine do begin
            "Additional-Currency Posting" := "Additional-Currency Posting"::None;
            Validate(Amount, Amt);

            GetGLSetup;
            if GLSetup."Additional Reporting Currency" <> '' then begin
                "Source Currency Code" := GLSetup."Additional Reporting Currency";
                "Source Currency Amount" := AmtACY;
                if (Amount = 0) and ("Source Currency Amount" <> 0) then begin
                    "Additional-Currency Posting" :=
                      "Additional-Currency Posting"::"Additional-Currency Amount Only";
                    Validate(Amount, "Source Currency Amount");
                    "Source Currency Amount" := 0;
                end;
            end;
        end;

        exit((Amt <> 0) or (AmtACY <> 0));
    end;

    procedure SetDesc(var GenJnlLine: Record "Gen. Journal Line"; InvtPostBuf: Record "EN Invt. Posting Buffer")
    begin
        with InvtPostBuf do
            GenJnlLine.Description :=
              CopyStr(
                StrSubstNo(
                  Text001,
                  "Account Type", "Bal. Account Type",
                  "Location Code", "Inventory Posting Group",
                  "Gen. Bus. Posting Group", "Gen. Prod. Posting Group"),
                1, MaxStrLen(GenJnlLine.Description));
    end;

    local procedure InsertTempInvtPostToGLTestBuf(GenJnlLine: Record "Gen. Journal Line"; ValueEntry: Record "Value Entry")
    begin
        with GenJnlLine do begin
            TempInvtPostToGLTestBuf.Init;
            TempInvtPostToGLTestBuf."Line No." := GetNextLineNo;
            TempInvtPostToGLTestBuf."Posting Date" := "Posting Date";
            TempInvtPostToGLTestBuf."Document No." := "Document No.";
            TempInvtPostToGLTestBuf.Description := Description;
            TempInvtPostToGLTestBuf."Account No." := "Account No.";
            TempInvtPostToGLTestBuf.Amount := Amount;
            TempInvtPostToGLTestBuf."Source Code" := "Source Code";
            TempInvtPostToGLTestBuf."System-Created Entry" := true;
            TempInvtPostToGLTestBuf."Value Entry No." := ValueEntry."Entry No.";
            TempInvtPostToGLTestBuf."Additional-Currency Posting" := "Additional-Currency Posting";
            TempInvtPostToGLTestBuf."Source Currency Code" := "Source Currency Code";
            TempInvtPostToGLTestBuf."Source Currency Amount" := "Source Currency Amount";
            TempInvtPostToGLTestBuf."Inventory Account Type" := GlobalInvtPostBuf."Account Type";
            TempInvtPostToGLTestBuf."Dimension Set ID" := "Dimension Set ID";
            if GlobalInvtPostBuf.UseInvtPostSetup then begin
                TempInvtPostToGLTestBuf."Location Code" := GlobalInvtPostBuf."Location Code";
                TempInvtPostToGLTestBuf."Invt. Posting Group Code" :=
                  GetInvPostingGroupCode(
                    ValueEntry,
                    TempInvtPostToGLTestBuf."Inventory Account Type" = TempInvtPostToGLTestBuf."Inventory Account Type"::"WIP Inventory",
                    GlobalInvtPostBuf."Inventory Posting Group")
            end else begin
                TempInvtPostToGLTestBuf."Gen. Bus. Posting Group" := GlobalInvtPostBuf."Gen. Bus. Posting Group";
                TempInvtPostToGLTestBuf."Gen. Prod. Posting Group" := GlobalInvtPostBuf."Gen. Prod. Posting Group";
            end;
            TempInvtPostToGLTestBuf.Insert;
        end;
    end;

    local procedure CreateGLItemLedgRelation(var ValueEntry: Record "Value Entry")
    var
        GLReg: Record "G/L Register";
    begin
        GenJnlPostLine.GetGLReg(GLReg);
        if GlobalPostPerPostGroup then begin
            TempGLItemLedgRelation.Reset;
            TempGLItemLedgRelation.SetRange("G/L Entry No.", GlobalInvtPostBuf."Entry No.");
            TempGLItemLedgRelation.FindSet;
            repeat
                ValueEntry.Get(TempGLItemLedgRelation."Value Entry No.");
                UpdateValueEntry(ValueEntry);
                CreateGLItemLedgRelationEntry(GLReg);
            until TempGLItemLedgRelation.Next = 0;
        end else begin
            UpdateValueEntry(ValueEntry);
            CreateGLItemLedgRelationEntry(GLReg);
        end;
    end;

    local procedure CreateGLItemLedgRelationEntry(GLReg: Record "G/L Register")
    var
        GLItemLedgRelation: Record "G/L - Item Ledger Relation";
    begin
        if GLReg."To Entry No." <> 0 then begin // P8004516
            GLItemLedgRelation.Init;
            GLItemLedgRelation."G/L Entry No." := GLReg."To Entry No.";
            GLItemLedgRelation."Value Entry No." := TempGLItemLedgRelation."Value Entry No.";
            GLItemLedgRelation."G/L Register No." := GLReg."No.";
            GLItemLedgRelation.Insert;
        end;                                    // P8004516
        TempGLItemLedgRelation."G/L Entry No." := GlobalInvtPostBuf."Entry No.";
        TempGLItemLedgRelation.Delete;
    end;

    local procedure UpdateValueEntry(var ValueEntry: Record "Value Entry")
    begin
        with ValueEntry do begin
            if GlobalInvtPostBuf."Interim Account" then begin
                "Expected Cost Posted to G/L" := "Cost Amount (Expected)";
                "Exp. Cost Posted to G/L (ACY)" := "Cost Amount (Expected) (ACY)";
            end else begin
                "Cost Posted to G/L" := "Cost Amount (Actual)";
                "Cost Posted to G/L (ACY)" := "Cost Amount (Actual) (ACY)";
            end;
            if not CalledFromItemPosting then
                Modify;
            
            ExtraChargeMgmt.UpdatePostedCharge("Entry No.", GlobalInvtPostBuf."Interim Account");
            
        end;
    end;

    procedure GetTempInvtPostToGLTestBuf(var InvtPostToGLTestBuf: Record "Invt. Post to G/L Test Buffer")
    begin
        InvtPostToGLTestBuf.DeleteAll;
        if not TempInvtPostToGLTestBuf.FindSet then
            exit;

        repeat
            InvtPostToGLTestBuf := TempInvtPostToGLTestBuf;
            InvtPostToGLTestBuf.Insert;
        until TempInvtPostToGLTestBuf.Next = 0;
    end;

    procedure GetAmtToPost(var NewCOGSAmt: Decimal; var NewInvtAdjmtAmt: Decimal; var NewDirCostAmt: Decimal; var NewOvhdCostAmt: Decimal; var NewVarPurchCostAmt: Decimal; var NewVarMfgDirCostAmt: Decimal; var NewVarMfgOvhdCostAmt: Decimal; var NewWIPInvtAmt: Decimal; var NewInvtAmt: Decimal; GetTotal: Boolean)
    begin
        GetAmt(NewInvtAdjmtAmt, InvtAdjmtAmt, TotalInvtAdjmtAmt, GetTotal);
        GetAmt(NewDirCostAmt, DirCostAmt, TotalDirCostAmt, GetTotal);
        GetAmt(NewOvhdCostAmt, OvhdCostAmt, TotalOvhdCostAmt, GetTotal);
        GetAmt(NewVarPurchCostAmt, VarPurchCostAmt, TotalVarPurchCostAmt, GetTotal);
        GetAmt(NewVarMfgDirCostAmt, VarMfgDirCostAmt, TotalVarMfgDirCostAmt, GetTotal);
        GetAmt(NewVarMfgOvhdCostAmt, VarMfgOvhdCostAmt, TotalVarMfgOvhdCostAmt, GetTotal);
        GetAmt(NewWIPInvtAmt, WIPInvtAmt, TotalWIPInvtAmt, GetTotal);
        GetAmt(NewCOGSAmt, COGSAmt, TotalCOGSAmt, GetTotal);
        GetAmt(NewInvtAmt, InvtAmt, TotalInvtAmt, GetTotal);
    end;

    local procedure GetAmt(var NewAmt: Decimal; var Amt: Decimal; var TotalAmt: Decimal; GetTotal: Boolean)
    begin
        if GetTotal then
            NewAmt := TotalAmt
        else begin
            NewAmt := Amt;
            TotalAmt := TotalAmt + Amt;
            Amt := 0;
        end;
    end;

    procedure GetInvtPostBuf(var InvtPostBuf: Record "EN Invt. Posting Buffer")
    begin
        InvtPostBuf.DeleteAll;

        GlobalInvtPostBuf.Reset;
        if GlobalInvtPostBuf.FindSet then
            repeat
                InvtPostBuf := GlobalInvtPostBuf;
                InvtPostBuf.Insert;
            until GlobalInvtPostBuf.Next = 0;
    end;

    local procedure GetInvPostingGroupCode(ValueEntry: Record "Value Entry"; WIPInventory: Boolean; InvPostingGroupCode: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        if WIPInventory then
            if ValueEntry."Source No." <> ValueEntry."Item No." then
                if Item.Get(ValueEntry."Source No.") then
                    exit(Item."Inventory Posting Group");

        exit(InvPostingGroupCode);
    end;

    local procedure SetPostGrpsABC(ValueEntry: Record "Value Entry"; Resource: Record Resource; var InvtPostBuf: Record "EN Invt. Posting Buffer")
    begin
        // P8000375A, P8000466A
        with InvtPostBuf do begin
            "Location Code" := ValueEntry."Location Code";
            "Inventory Posting Group" := ValueEntry."Inventory Posting Group";
            "Gen. Bus. Posting Group" := ValueEntry."Gen. Bus. Posting Group";
            "Gen. Prod. Posting Group" := Resource."Gen. Prod. Posting Group";
        end;
    end;

    [Scope('Internal')]
    procedure GetGLRegister(var GLReg2: Record "G/L Register"; var NextVATEntryNo2: Integer; var NextTransactionNo2: Integer)
    begin
        //GenJnlPostLine.GetGLRegister(GLReg2, NextVATEntryNo2, NextTransactionNo2); // P8000888 ///EN
    end;

    [Scope('Internal')]
    procedure SetGLRegister(var GLReg2: Record "G/L Register"; NextVATEntryNo2: Integer; NextTransactionNo2: Integer)
    begin
        //GenJnlPostLine.SetGLRegister(GLReg2, NextVATEntryNo2, NextTransactionNo2); // P8000888 ///EN
    end;

    [Scope('Internal')]
    procedure ResetGLReg(): Boolean
    var
        GLReg: Record "G/L Register";
        LastGLReg: Record "G/L Register";
    begin
        // P8001227
        GenJnlPostLine.GetGLReg(GLReg);
        if (GLReg."No." <> 0) then begin
            LastGLReg.FindLast;
            exit(LastGLReg."No." <> GLReg."No.");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBufferSalesPosting(var TempInvtPostingBuffer: Record "EN Invt. Posting Buffer" temporary; ValueEntry: Record "Value Entry"; PostBufDimNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcCostToPostFromBuffer(var ValueEntry: Record "Value Entry"; var CostToPost: Decimal; var CostToPostACY: Decimal; var ExpCostToPost: Decimal; var ExpCostToPostACY: Decimal)
    begin
    end;

    


    

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostInvtPostBuf(var GenJournalLine: Record "Gen. Journal Line"; var InvtPostingBuffer: Record "EN Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

}

