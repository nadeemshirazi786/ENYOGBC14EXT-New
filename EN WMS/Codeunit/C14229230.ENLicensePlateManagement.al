/// <summary>
/// Codeunit EN License Plate Management (ID 14229230).
/// </summary>
codeunit 14229230 "License Plate Mgmt. ELA"
{

    /// <summary>
    /// CreateNewLicensePlate.
    /// </summary>
    /// <param name="ManualLicensePlateNo">code[20].</param>
    /// <param name="LicensePlateType">code[10].</param>
    /// <returns>Return value of type code[20].</returns>
    procedure CreateNewLicensePlate(ManualLicensePlateNo: code[20]; LicensePlateType: code[10]): code[20]
    var
        LicensePlate: Record "License Plate ELA";
    begin
        LicensePlate.Init();
        if ManualLicensePlateNo <> '' then
            LicensePlate."No." := ManualLicensePlateNo;

        LicensePlate.Validate(Type, LicensePlateType);
        LicensePlate.Insert(true);
        exit(LicensePlate."No.");
    end;


    /// <summary>
    /// GetLicensePlateByContainerNo.
    /// </summary>
    /// <param name="ContainerNo">code[20].</param>
    /// <param name="ContainerType">code[10].</param>
    /// <returns>Return value of type code[20].</returns>
    procedure GetLicensePlateByContainerNo(ContainerNo: code[20]; ContainerType: code[10]): code[20]
    var
        Container: Record "Container ELA";
        ContainerContent: record "Container Content ELA";
    begin
        // Container.Get(ContainerNo);
        ContainerContent.reset;
        ContainerContent.SetRange("Container No.", ContainerNo);
        ContainerContent.SetFilter("License Plate No.", '<>''''');
        if ContainerContent.FindLast() then
            exit(ContainerContent."License Plate No.")
        else
            exit(CreateNewLicensePlate('', ContainerType));
    end;

    procedure AddContentToLicensePlate()
    var
        myInt: Integer;
    begin

    end;

    procedure RemoveContentFromLicensePlate()
    var
        myInt: Integer;
    begin

    end;


    procedure CreateInternalLicensePlate()
    var
        myInt: Integer;
    begin

    end;


    procedure GetLicensePlateNo()
    var
        myInt: Integer;
    begin

    end;

}
