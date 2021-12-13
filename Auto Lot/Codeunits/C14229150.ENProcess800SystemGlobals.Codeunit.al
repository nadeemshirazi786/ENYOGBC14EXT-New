/// <summary>
/// Codeunit Process 800 System Globals ELA (ID 14229150).
/// </suummary>
codeunit 14229150 "Process 800 System Globals ELA"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        ADCDebugMode: Boolean;
        PrinterOverride: Text[250];
        ADCMsgPos: array[2] of Integer;


    /// <summary>
    /// SetPrinterOverride.
    /// </summary>
    /// <param name="PrinterName">Text[250].</param>
    [Scope('Internal')]
    procedure SetPrinterOverride(PrinterName: Text[250])
    begin
        PrinterOverride := PrinterName;
    end;


    /// <summary>
    /// GetPrinterOverride.
    /// </summary>
    /// <returns>Return value of type Text[250].</returns>
    [Scope('Internal')]
    procedure GetPrinterOverride(): Text[250]
    begin
        exit(PrinterOverride);
    end;


    /// <summary>
    /// MultipleLotCode.
    /// </summary>
    /// <returns>Return value of type Code[20].</returns>
    procedure MultipleLotCode(): Code[20]
    var
        Text001: Label '*MULTIPLE*';
    begin
        exit(Text001);
    end;

    /// <summary>
    /// DeveloperLicenseNo.
    /// </summary>
    /// <returns>Return value of type Text[20].</returns>
    [Scope('Internal')]
    procedure DeveloperLicenseNo(): Text[20]
    begin

        exit('5215109');
    end;
}

