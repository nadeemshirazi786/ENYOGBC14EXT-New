/// <summary>
/// Codeunit Process 800 Functions ELA (ID 14229155).
/// </summary>
codeunit 14229155 "Process 800 Functions ELA"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        LicensePermission: Record "License Permission";
        Logo: Code[10];
        Text37002000: Label 'DEMO';
        Text37002001: Label 'Work date set to %1.';
        Text37002002: Label 'Process 800 (&Worldwide),Process 800 (&Regional),&Customer';
        VPSValidation: Boolean;
/// <summary>
/// IsTableReadAllowed.
/// </summary>
/// <param name="TableNo">Integer.</param>
/// <returns>Return value of type Boolean.</returns>
    local procedure IsTableReadAllowed(TableNo: Integer): Boolean
    begin
        if (LicensePermission."Object Number" <> TableNo) then
            LicensePermission.Get(LicensePermission."Object Type"::Table, TableNo);
        exit(LicensePermission."Read Permission" = LicensePermission."Read Permission"::Yes);
    end;

/// <summary>
/// IsCodeunitReadAllowed.
/// </summary>
/// <param name="CodeunitNo">Integer.</param>
/// <returns>Return value of type Boolean.</returns>
    local procedure IsCodeunitReadAllowed(CodeunitNo: Integer): Boolean
    begin
        if (LicensePermission."Object Number" <> CodeunitNo) then
            LicensePermission.Get(LicensePermission."Object Type"::Codeunit, CodeunitNo);
        exit(LicensePermission."Read Permission" = LicensePermission."Read Permission"::Yes);
    end;

/// <summary>
/// ProductEnabled.
/// </summary>
/// <param name="ProductCode">Code[10].</param>
/// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure ProductEnabled(ProductCode: Code[10]): Boolean
    begin
    end;
/// <summary>
/// ForecastInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure ForecastInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Production Forecast Entry"));
    end;

/// <summary>
/// TrackingInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    procedure TrackingInstalled(): Boolean
    begin

    end;

/// <summary>
/// PricingInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    procedure PricingInstalled(): Boolean
    begin

    end;

/// <summary>
/// DistPlanningInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    procedure DistPlanningInstalled(): Boolean
    begin

    end;

/// <summary>
/// AltQtyInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    procedure AltQtyInstalled(): Boolean
    begin

    end;
/// <summary>
/// ProcessInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure ProcessInstalled(): Boolean
    begin
    end;
/// <summary>
/// QCInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure QCInstalled(): Boolean
    begin

    end;
/// <summary>
/// PkgConfInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure PkgConfInstalled(): Boolean
    begin

    end;
/// <summary>
/// CoProductsInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure CoProductsInstalled(): Boolean
    begin

    end;
/// <summary>
/// ContainerTrackingInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure ContainerTrackingInstalled(): Boolean
    begin

    end;
/// <summary>
/// MSDSInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure MSDSInstalled(): Boolean
    begin

    end;
/// <summary>
/// FreshProInstalled.
/// </summary>
/// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure FreshProInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure DataCollectionInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure LabelsInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure AccrualsInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure DedMgtInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure MaintenanceInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure RepackInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure WhseInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure AdvWhseInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure CommCostInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure ProcessDataCollectionInstalled(): Boolean
    begin
    end;

    [Scope('Internal')]
    procedure AllergenInstalled(): Boolean
    begin
    end;

    [Scope('Internal')]
    procedure ItemLifecycleInstalled(): Boolean
    begin
    end;

    [Scope('Internal')]
    procedure DocumentLifecycleInstalled(): Boolean
    begin

    end;

    [Scope('Internal')]
    procedure VisProdSequencerInstalled(): Boolean
    begin
    end;

    [Scope('Internal')]
    procedure GetLogo(): Code[10]
    begin
        exit(Logo);
    end;

    [Scope('Internal')]
    procedure SetDemoWorkDate()
    var
        DefaultDate: Date;
    begin

        if CurrentExecutionMode = EXECUTIONMODE::Debug then
            exit;

        DefaultDate := GetDemoDate;
        if DefaultDate <> WorkDate then begin
            WorkDate := DefaultDate;
            Message(Text37002001, WorkDate);
        end;
    end;


    procedure GetDemoDate() DefaultDate: Date
    var
        AcctPer: Record "Accounting Period";

    begin

        DefaultDate := Today;

        exit;

        if StrPos(UpperCase(CompanyName), Text37002000) = 0 then
            exit;

        if AcctPer.Find('-') then
            exit(DMY2Date(15, 7, Date2DMY(AcctPer."Starting Date", 3) + 2));
    end;

    [Scope('Internal')]
    procedure SetUIDOffset(): Integer
    var
        DefaultChoice: Integer;
        Selection: Integer;
    begin
        exit(50000);

        if StrPos(UpperCase(CompanyName), Text37002000) <> 0 then
            exit(50000);
        if StrPos(UpperCase(CompanyName), 'P800') <> 0 then
            if StrPos(UpperCase(CompanyName), 'P800 W1') <> 0 then
                DefaultChoice := 1
            else
                DefaultChoice := 2
        else
            DefaultChoice := 3;

        Selection := StrMenu(Text37002002, DefaultChoice);
        if Selection = 0 then
            Selection := DefaultChoice;

        case Selection of
            1:
                exit(37002000);
            2:
                exit(37002500);
            3:
                exit(50000);
        end;

    end;


    procedure SelectRoleCenter(var SelectedRoleCenter: Integer)
    var

        UserPersonalization: Record "User Personalization";
        "Profile": Record "Profile";
    begin

    end;


    procedure RunSalesPrices(SourceRec: Variant; Modal: Boolean)
    var
        SourceRecRef: RecordRef;
        SalesPrice: Record "Sales Price";
        CustomerPriceGroup: Record "Customer Price Group";
        Customer: Record Customer;
        Item: Record Item;
        Campaign: Record Campaign;
    begin
        if SourceRec.IsRecord then begin
            SourceRecRef.GetTable(SourceRec);

            case SourceRecRef.Number of
                DATABASE::"Customer Price Group":
                    begin
                        CustomerPriceGroup := SourceRec;
                        SalesPrice.SetCurrentKey("Sales Type", "Sales Code");
                        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
                        SalesPrice.SetRange("Sales Code", CustomerPriceGroup.Code);
                        SalesPrice."Sales Type" := SalesPrice."Sales Type"::"Customer Price Group";
                        SalesPrice."Sales Code" := CustomerPriceGroup.Code;
                    end;
                DATABASE::Customer:
                    begin
                        Customer := SourceRec;
                        SalesPrice.SetCurrentKey("Sales Type", "Sales Code");
                        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Customer);
                        SalesPrice.SetRange("Sales Code", Customer."No.");
                        SalesPrice."Sales Type" := SalesPrice."Sales Type"::Customer;
                        SalesPrice."Sales Code" := Customer."No.";
                    end;
                DATABASE::Item:
                    begin
                        Item := SourceRec;
                    end;
                DATABASE::Campaign:
                    begin
                        Campaign := SourceRec;
                        SalesPrice.SetCurrentKey("Sales Type", "Sales Code");
                        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Campaign);
                        SalesPrice.SetRange("Sales Code", Campaign."No.");
                        SalesPrice."Sales Type" := SalesPrice."Sales Type"::Campaign;
                        SalesPrice."Sales Code" := Campaign."No.";
                    end;
            end;
        end;

    end;

    [Scope('Internal')]
    procedure RunSalesLineDiscounts(SourceRec: Variant; Modal: Boolean)
    var
        SourceRecRef: RecordRef;
        SalesLineDiscount: Record "Sales Line Discount";
        Customer: Record Customer;
        Item: Record Item;
        CustomerDiscountGroup: Record "Customer Discount Group";
        ItemDiscountGroup: Record "Item Discount Group";
        Campaign: Record Campaign;
    begin
        if SourceRec.IsRecord then begin
            SourceRecRef.GetTable(SourceRec);

            case SourceRecRef.Number of
                DATABASE::Customer:
                    begin
                        Customer := SourceRec;
                        SalesLineDiscount.SetCurrentKey("Sales Type", "Sales Code");
                        SalesLineDiscount.SetRange("Sales Type", SalesLineDiscount."Sales Type"::Customer);
                        SalesLineDiscount.SetRange("Sales Code", Customer."No.");
                        SalesLineDiscount."Sales Type" := SalesLineDiscount."Sales Type"::Customer;
                        SalesLineDiscount."Sales Code" := Customer."No.";
                    end;
                DATABASE::Item:
                    begin

                    end;
                DATABASE::"Customer Discount Group":
                    begin
                        CustomerDiscountGroup := SourceRec;
                        SalesLineDiscount.SetCurrentKey("Sales Type", "Sales Code");
                        SalesLineDiscount.SetRange("Sales Type", SalesLineDiscount."Sales Type"::"Customer Disc. Group");
                        SalesLineDiscount.SetRange("Sales Code", CustomerDiscountGroup.Code);
                        SalesLineDiscount."Sales Type" := SalesLineDiscount."Sales Type"::"Customer Disc. Group";
                        SalesLineDiscount."Sales Code" := CustomerDiscountGroup.Code;
                    end;
                DATABASE::"Item Discount Group":
                    begin

                    end;
                DATABASE::Campaign:
                    begin
                        Campaign := SourceRec;
                        SalesLineDiscount.SetCurrentKey("Sales Type", "Sales Code");
                        SalesLineDiscount.SetRange("Sales Type", SalesLineDiscount."Sales Type"::Campaign);
                        SalesLineDiscount.SetRange("Sales Code", Campaign."No.");
                        SalesLineDiscount."Sales Type" := SalesLineDiscount."Sales Type"::Campaign;
                        SalesLineDiscount."Sales Code" := Campaign."No.";
                    end;
            end;
        end;

    end;

    [Scope('Internal')]
    local procedure PageToRun(Enhanced: Boolean; StandardPageID: Integer; EnhancedPageID: Integer): Integer
    begin
        if Enhanced then
            exit(EnhancedPageID)
        else
            exit(StandardPageID);
    end;

    [Scope('Internal')]
    procedure SetVPSValidation(Set: Boolean)
    begin
        VPSValidation := Set;
    end;

    [Scope('Internal')]
    procedure GetVPSValidation(): Boolean
    begin
        if VPSValidation then begin
            Clear(VPSValidation);
            exit(true);
        end;
    end;
}

