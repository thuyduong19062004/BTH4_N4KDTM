https://drive.google.com/drive/folders/1e0BH0n8b2IexLYnMqQ6L-M42DdFTi-yz
wait 8

students = ["2251162213","2251162038","2251162154"]
count = len(students)

for i from 0 to count-1
    student = students[i]
    echo "Checking student: " + student
    
    click //input[@aria-label='Tìm trong Drive']
    wait 1
    type //input[@aria-label='Tìm trong Drive'] as student
    keyboard [enter]
    wait 8
    
    exist = present("//div[@role='gridcell' and contains(@aria-label,'" + student + "')]")
    
    files = xpath_all("//div[@role='gridcell']")
    if len(files) > 0
        echo "Files found for student " + student + ":"
        for f from 0 to len(files)-1
            echo "  - " + files[f].innerText()
        end for
    else
        echo "No files found for student " + student
    end if
    
    if exist
        url = "https://script.google.com/macros/s/AKfycbzhWlj5zFNGzzlrp1lgEihkK5DPRautDZP35h7-GHeAKxvceVZZnalOc5ovJHy98U-gjQ/exec?msv=" + student + "&nopbai=Da%20nop"
    else
        url = "https://script.google.com/macros/s/AKfycbzhWlj5zFNGzzlrp1lgEihkK5DPRautDZP35h7-GHeAKxvceVZZnalOc5ovJHy98U-gjQ/exec?msv=" + student + "&nopbai=Chua%20nop"

    js window.open(url)
    wait 2

    type //input[@aria-label='Tìm trong Drive'] as [clear]
    wait 2
end for
