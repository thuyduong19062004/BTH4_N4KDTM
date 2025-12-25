https://drive.google.com/drive/folders/1e0BH0n8b2IexLYnMqQ6L-M42DdFTi-yz
wait 8


// ================= SINH VIÊN 1 =================
click //input[@aria-label='Tìm trong Drive']
wait 1
type //input[@aria-label='Tìm trong Drive'] as 2251162213[enter]
wait 8

exist1 = present("//div[@role='gridcell' and contains(@aria-label,'2251162213')]")
if exist1
    url = "https://script.google.com/macros/s/AKfycbzhWlj5zFNGzzlrp1lgEihkK5DPRautDZP35h7-GHeAKxvceVZZnalOc5ovJHy98U-gjQ/exec?msv=2251162213&nopbai=Da%20nop"
else
    url = "https://script.google.com/macros/s/AKfycbzhWlj5zFNGzzlrp1lgEihkK5DPRautDZP35h7-GHeAKxvceVZZnalOc5ovJHy98U-gjQ/exec?msv=2251162213&nopbai=Chua%20nop"

js window.open(url)
wait 2
type //input[@aria-label='Tìm trong Drive'] as [clear]
wait 2


// ================= SINH VIÊN 2 =================
click //input[@aria-label='Tìm trong Drive']
wait 1
type //input[@aria-label='Tìm trong Drive'] as 2251162038[enter]
wait 8

exist2 = present("//div[@role='gridcell' and contains(@aria-label,'2251162038')]")
if exist2
    url = "https://script.google.com/macros/s/AKfycbzhWlj5zFNGzzlrp1lgEihkK5DPRautDZP35h7-GHeAKxvceVZZnalOc5ovJHy98U-gjQ/exec?msv=2251162038&nopbai=Da%20nop"
else
    url = "https://script.google.com/macros/s/AKfycbzhWlj5zFNGzzlrp1lgEihkK5DPRautDZP35h7-GHeAKxvceVZZnalOc5ovJHy98U-gjQ/exec?msv=2251162038&nopbai=Chua%20nop"

js window.open(url)
wait 2
type //input[@aria-label='Tìm trong Drive'] as [clear]
wait 2


// ================= SINH VIÊN 3 =================
click //input[@aria-label='Tìm trong Drive']
wait 1
type //input[@aria-label='Tìm trong Drive'] as 2251162154[enter]
wait 8

exist3 = present("//div[@role='gridcell' and contains(@aria-label,'2251162154')]")
if exist3
    url = "https://script.google.com/macros/s/AKfycbzhWlj5zFNGzzlrp1lgEihkK5DPRautDZP35h7-GHeAKxvceVZZnalOc5ovJHy98U-gjQ/exec?msv=2251162154&nopbai=Da%20nop"
else
    url = "https://script.google.com/macros/s/AKfycbzhWlj5zFNGzzlrp1lgEihkK5DPRautDZP35h7-GHeAKxvceVZZnalOc5ovJHy98U-gjQ/exec?msv=2251162154&nopbai=Chua%20nop"

js window.open(url)
wait 2
