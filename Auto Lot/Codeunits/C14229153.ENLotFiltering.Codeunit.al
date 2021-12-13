/// <summary>
/// Codeunit Lot Filtering ELA (ID 14229153).
/// </summary>
codeunit 14229153 "Lot Filtering ELA"
{

    trigger OnRun()
    begin
    end;

    var
        AgingDate: Date;
        LotAgeDate: Date;
        Text001: Label 'Age';
        Text002: Label 'Category';
        Text003: Label 'Days to Expire';
        LotAgeProfileCode: Code[10];
    /// <summary>
    /// SetAgingDate.
    /// </summary>
    /// <param name="AgeDate">Date.</param>
    [Scope('Internal')]
    procedure SetAgingDate(AgeDate: Date)
    begin
        AgingDate := AgeDate;
    end;
    /// <summary>
    /// GetLotAge.
    /// </summary>
    /// <param name="LotInfo">Record "Lot No. Information".</param>
    local procedure GetLotAge(LotInfo: Record "Lot No. Information")
    var
        AgeDate: Date;
    begin
        if AgingDate = 0D then
            AgeDate := Today
        else
            AgeDate := AgingDate;
    end;
    /// <summary>
    /// ClearLotAge.
    /// </summary>
    /// <param name="LotInfo">Record "Lot No. Information".</param>
    [Scope('Internal')]
    procedure ClearLotAge(LotInfo: Record "Lot No. Information")
    begin

    end;
    /// <summary>
    /// Age.
    /// </summary>
    /// <param name="LotInfo">Record "Lot No. Information".</param>
    /// <returns>Return value of type Integer.</returns>
    [Scope('Internal')]
    procedure Age(LotInfo: Record "Lot No. Information"): Integer
    begin
        GetLotAge(LotInfo);
        exit(1);
    end;
    /// <summary>
    /// AgeCategory.
    /// </summary>
    /// <param name="LotInfo">Record "Lot No. Information".</param>
    /// <returns>Return value of type Code[10].</returns>
    [Scope('Internal')]
    procedure AgeCategory(LotInfo: Record "Lot No. Information"): Code[10]
    begin
        GetLotAge(LotInfo);

    end;
    /// <summary>
    /// AgeDate.
    /// </summary>
    /// <param name="LotInfo">Record "Lot No. Information".</param>
    /// <returns>Return value of type Date.</returns>
    [Scope('Internal')]
    procedure AgeDate(LotInfo: Record "Lot No. Information"): Date
    begin
        GetLotAge(LotInfo);

    end;
    /// <summary>
    /// RemainingDays.
    /// </summary>
    /// <param name="LotInfo">Record "Lot No. Information".</param>
    /// <returns>Return value of type Integer.</returns>
    [Scope('Internal')]
    procedure RemainingDays(LotInfo: Record "Lot No. Information"): Integer
    begin
        GetLotAge(LotInfo);

    end;
    /// <summary>
    /// DaysToExpire.
    /// </summary>
    /// <param name="LotInfo">Record "Lot No. Information".</param>
    /// <returns>Return value of type Integer.</returns>
    [Scope('Internal')]
    procedure DaysToExpire(LotInfo: Record "Lot No. Information"): Integer
    begin

        GetLotAge(LotInfo);

    end;
    /// <summary>
    /// LotInFilter.
    /// </summary>
    /// <param name="LotInfo">Record "Lot No. Information".</param>
    /// <param name="LotSpecFilter">Temporary VAR Record "EN Lot Specf. Filter ELA".</param>
    /// <param name="FreshnessMethod">Option " ","Days To Fresh","Best If Used By","Sell By".</param>
    /// <param name="OldestAcceptableDate">Date.</param>
    /// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure LotInFilter(LotInfo: Record "Lot No. Information"; var LotSpecFilter: Record "EN Lot Specf. Filter ELA" temporary; FreshnessMethod: Option " ","Days To Fresh","Best If Used By","Sell By"; OldestAcceptableDate: Date): Boolean
    var
        LotSpec: Record "EN Lot Specification ELA";
        Item: Record Item;
    begin
        if OldestAcceptableDate <> 0D then
            case FreshnessMethod of
                FreshnessMethod::"Days To Fresh":
                    if LotInfo."Creation Date ELA" < OldestAcceptableDate then
                        exit(false);
                FreshnessMethod::"Best If Used By", FreshnessMethod::"Sell By":
                    exit(false);
            end;
        GetLotAge(LotInfo);
    end;
    /// <summary>
    /// LotSpecAssist.
    /// </summary>
    /// <param name="LotSpecFilter">Temporary VAR Record "EN Lot Specf. Filter ELA".</param>
    /// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure LotSpecAssist(var LotSpecFilter: Record "EN Lot Specf. Filter ELA" temporary): Boolean
    var
        InvSetup: Record "Inventory Setup";
        LotSpecCat: Record "EN Lot Specification ELA";
        SpecFilter: Record "EN Lot Specf. Filter ELA" temporary;
        ShortcutSpec: array[5] of Code[10];
        i: Integer;
    begin

    end;
    /// <summary>
    /// LotAgeText.
    /// </summary>
    /// <param name="LotAgeFilter">Record "EN Lot Age Filter ELA".</param>
    /// <returns>Return variable SpecText of type Text[1024].</returns>
    [Scope('Internal')]
    procedure LotAgeText(LotAgeFilter: Record "EN Lot Age Filter ELA") SpecText: Text[1024]
    begin
        if LotAgeFilter."Age Filter" <> '' then
            SpecText := SpecText + StrSubstNo(', %1: %2', Text001, LotAgeFilter."Age Filter");
        if LotAgeFilter."Category Filter" <> '' then
            SpecText := SpecText + StrSubstNo(', %1: %2', Text002, LotAgeFilter."Category Filter");

        if LotAgeFilter."Days to Expire Filter" <> '' then
            SpecText := SpecText + StrSubstNo(', %1: %2', Text003, LotAgeFilter."Days to Expire Filter");
        SpecText := CopyStr(SpecText, 3);
    end;
    /// <summary>
    /// LotSpecText.
    /// </summary>
    /// <param name="LotSpecFilter">Temporary VAR Record "EN Lot Specf. Filter ELA".</param>
    /// <returns>Return variable SpecText of type Text[1024].</returns>
    [Scope('Internal')]
    procedure LotSpecText(var LotSpecFilter: Record "EN Lot Specf. Filter ELA" temporary) SpecText: Text[1024]
    var
        LotSpecCat: Record "EN Data Collct. Data Elmnt ELA";
    begin
        LotSpecFilter.Reset;
        if LotSpecFilter.Find('-') then
            repeat
                LotSpecCat.Get(LotSpecFilter."Data Element Code");
                SpecText := SpecText + ', ' + LotSpecCat.Description + ': ' + LotSpecFilter.Filter;
            until LotSpecFilter.Next = 0;
        SpecText := CopyStr(SpecText, 3);
    end;
    /// <summary>
    /// ItemAgeSummary.
    /// </summary>
    /// <param name="LotInfo">VAR Record "Lot No. Information".</param>
    /// <param name="LotSpecFilter">Temporary VAR Record "EN Lot Specf. Filter ELA".</param>
    [Scope('Internal')]
    procedure ItemAgeSummary(var LotInfo: Record "Lot No. Information"; var LotSpecFilter: Record "EN Lot Specf. Filter ELA" temporary)
    var
        Item: Record Item;
        ItemCat: Record "Item Category";
        LotInfo2: Record "Lot No. Information";
    begin

    end;
    /// <summary>
    /// CheckLotPreferences.
    /// </summary>
    /// <param name="LotInfo">Record "Lot No. Information".</param>
    /// <param name="LotAgeFilter">VAR Record "EN Lot Age Filter ELA".</param>
    /// <param name="LotSpecFilter">VAR Record "EN Lot Specf. Filter ELA".</param>
    /// <param name="FreshnessMethod">Option " ","Days To Fresh","Best If Used By","Sell By".</param>
    /// <param name="OldestAcceptableDate">Date.</param>
    /// <param name="ShowWarning">Boolean.</param>
    /// <param name="EnforcementLevel">Option Warning,Error.</param>
    /// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure CheckLotPreferences(LotInfo: Record "Lot No. Information"; var LotAgeFilter: Record "EN Lot Age Filter ELA"; var LotSpecFilter: Record "EN Lot Specf. Filter ELA"; FreshnessMethod: Option " ","Days To Fresh","Best If Used By","Sell By"; OldestAcceptableDate: Date; ShowWarning: Boolean; EnforcementLevel: Option Warning,Error): Boolean
    var
        LotSpec: Record "EN Lot Specification ELA";
        Warning: Boolean;
        AgeWarning: Boolean;
        AgeCatWarning: Boolean;
        FreshWarning: Boolean;
    begin

        if (not LotAgeFilter.Find('-')) and (not LotSpecFilter.Find('-')) and (FreshnessMethod = 0) then // P8001070
            exit(true);

        if LotAgeFilter.Find('-') then begin
            GetLotAge(LotInfo);
            if LotAgeFilter."Age Filter" <> '' then begin
                Warning := AgeWarning;
            end;
            if Warning and (not ShowWarning) then
                exit(false);

            if LotAgeFilter."Category Filter" <> '' then begin
                Warning := Warning or AgeCatWarning;
            end;
            if Warning and (not ShowWarning) then
                exit(false);
        end;

        LotSpec.SetRange("Item No.", LotInfo."Item No.");
        LotSpec.SetRange("Variant Code", LotInfo."Variant Code");
        LotSpec.SetRange("Lot No.", LotInfo."Lot No.");
        if LotSpecFilter.Find('-') then
            repeat
                LotSpec.SetRange("Data Element Code", LotSpecFilter."Data Element Code");
                LotSpec.SetRange("Boolean Value");
                LotSpec.SetRange("Date Value");
                LotSpec.SetRange("Lookup Value");
                LotSpec.SetRange("Numeric Value");
                LotSpec.SetRange("Text Value");
                case LotSpecFilter."Data Element Type" of
                    LotSpecFilter."Data Element Type"::Boolean:
                        LotSpec.SetFilter("Boolean Value", LotSpecFilter.Filter);
                    LotSpecFilter."Data Element Type"::Date:
                        LotSpec.SetFilter("Date Value", LotSpecFilter.Filter);
                    LotSpecFilter."Data Element Type"::Numeric:
                        LotSpec.SetFilter("Numeric Value", LotSpecFilter.Filter);
                    LotSpecFilter."Data Element Type"::Text:
                        LotSpec.SetFilter("Text Value", LotSpecFilter.Filter);
                end;
                if not LotSpec.Find('-') then begin
                    LotSpecFilter.Mark(true);
                    Warning := true;
                    if not ShowWarning then
                        exit(false);
                end;
            until LotSpecFilter.Next = 0;


        case FreshnessMethod of
            FreshnessMethod::"Days To Fresh":
                FreshWarning := LotInfo."Creation Date ELA" < OldestAcceptableDate;
        end;
        Warning := Warning or FreshWarning;

        if not ShowWarning then
            exit(not Warning);
        if ShowWarning and (not Warning) then
            exit(true);

        GetLotAge(LotInfo);
        case EnforcementLevel of

            EnforcementLevel::Error:
                exit(false);
        end;

    end;
}

