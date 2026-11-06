INSERT INTO customer VALUES
    ('CU-01', 'Fictional Northstar Clinic'),
    ('CU-02', 'Fictional Harbor Fabrication'),
    ('CU-03', 'Fictional Beacon Studio');

INSERT INTO product VALUES
    ('SW-END', 'Endpoint protection annual seat', 'SOFTWARE'),
    ('SW-BACK', 'Cloud backup annual seat', 'SOFTWARE'),
    ('HW-EDGE', 'Edge appliance', 'HARDWARE'),
    ('HW-NAS', 'Backup appliance', 'HARDWARE');

INSERT INTO subscription VALUES
    ('SUB-01', 'CU-01', 'SW-END'),
    ('SUB-02', 'CU-01', 'SW-BACK'),
    ('SUB-03', 'CU-02', 'SW-END'),
    ('SUB-04', 'CU-03', 'SW-BACK');

INSERT INTO subscription_term VALUES
    ('T01', 'SUB-01', DATE '2024-07-01', DATE '2025-07-01', DATE '2024-06-20', 50, 12000, 7000),
    ('T02', 'SUB-01', DATE '2025-07-01', DATE '2026-07-01', DATE '2025-06-20', 60, 11000, 7500),
    ('T03', 'SUB-02', DATE '2025-03-01', DATE '2026-03-01', DATE '2025-02-15', 20, 24000, 15000),
    ('T04', 'SUB-03', DATE '2024-08-01', DATE '2025-08-01', DATE '2024-07-20', 25, 14000, 8000),
    ('T05', 'SUB-03', DATE '2025-08-01', DATE '2026-08-01', DATE '2025-07-10', 30, 13000, 8500),
    ('T06', 'SUB-04', DATE '2024-06-01', DATE '2025-06-01', DATE '2024-05-18', 10, 25000, 14000);

INSERT INTO hardware_sale_line VALUES
    ('H01', 'CU-01', 'HW-EDGE', DATE '2025-02-10', 3, 150000, 90000),
    ('H02', 'CU-01', 'HW-NAS', DATE '2025-04-01', 1, 320000, 240000),
    ('H03', 'CU-02', 'HW-EDGE', DATE '2025-05-15', 2, 160000, 95000),
    ('H04', 'CU-03', 'HW-NAS', DATE '2025-07-02', 1, 310000, 240000);

INSERT INTO hardware_asset VALUES
    ('A01', 'SYN-0001', 'H01', DATE '2025-02-12'),
    ('A02', 'SYN-0002', 'H01', DATE '2025-02-12'),
    ('A03', 'SYN-0003', 'H01', DATE '2025-07-03'),
    ('A04', 'SYN-0004', 'H02', DATE '2025-04-05'),
    ('A05', 'SYN-0005', 'H03', DATE '2025-05-20'),
    ('A06', 'SYN-0006', 'H03', DATE '2025-05-20');
