import sys

file_path = 'lib/screens/stadium_bookings_review_page.dart'
with open(file_path, 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    new_lines.append(line)
    if "if (status.toLowerCase() == 'pending') ...[" in line:
        # Find the end of this block
        pass
    if "ElevatedButton(" in line and "_ownerService.acceptBooking(bookingId)" in line:
        # We need to insert our new block after the end of the pending block.
        # But wait, it's easier to just look for the end of that list.
        pass

# Re-doing with a simpler approach: finding the last '],' of the Column children.
content = "".join(lines)
insertion_point = content.find("if (status.toLowerCase() == 'pending') ...[")
# Find the matching closing bracket for this if block
count = 0
found_start = False
end_index = -1
for i in range(insertion_point, len(content)):
    if content[i] == '[':
        count += 1
        found_start = True
    elif content[i] == ']':
        count -= 1
        if found_start and count == 0:
            end_index = i + 1
            break

if end_index != -1:
    addition = """
                    if (status.toLowerCase() == 'payment_submitted') ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _ownerService.confirmBooking(bookingId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('تأكيد الحجز النهائي'),
                      ),
                    ],"""
    new_content = content[:end_index] + addition + content[end_index:]
    with open(file_path, 'w') as f:
        f.write(new_content)
