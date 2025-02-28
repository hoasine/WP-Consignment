codeunit 70006 WP_DataRententionUtils
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        StartInstall();
    end;

    internal procedure StartInstall()
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        MandatoryMinimumRetentionDays: Integer;
        dailyConsignChecklist: Record "Daily Consignment Checklist";
        dailyConsignSalesDetails: Record "Daily Consign. Sales Details";
        dailyConsignSalesMissing: Record "Daily Consign. Sales Missing";
        TableFilters: JsonArray;
    begin
        MandatoryMinimumRetentionDays := 30;
        RetenPolAllowedTables.AddAllowedTable(Database::"Daily Consignment Checklist", dailyConsignChecklist.FieldNo(SystemCreatedAt),
                                                MandatoryMinimumRetentionDays, "Reten. Pol. Filtering"::Default, "Reten. Pol. Deleting"::Default, TableFilters);

        RetenPolAllowedTables.AddAllowedTable(Database::"Daily Consign. Sales Details", dailyConsignSalesDetails.FieldNo(SystemCreatedAt),
                                                MandatoryMinimumRetentionDays, "Reten. Pol. Filtering"::Default, "Reten. Pol. Deleting"::Default, TableFilters);

        RetenPolAllowedTables.AddAllowedTable(Database::"Daily Consign. Sales Missing", dailyConsignSalesMissing.FieldNo(SystemCreatedAt),
                                                MandatoryMinimumRetentionDays, "Reten. Pol. Filtering"::Default, "Reten. Pol. Deleting"::Default, TableFilters);
    end;
}