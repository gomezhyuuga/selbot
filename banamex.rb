require 'watir-webdriver'
require 'csv'
require 'byebug'


def read_answers(file)
  data    = CSV.read(file)
  answers = Hash.new

  data.each do |row|
    url    = row[0].strip
    answer = row[1].strip.downcase
    answers[url] = answer
  end

  answers
end
def random_wait
  treshold = 1
  0.2 + Random.new.rand(treshold * 900) / 1000.0
end

ANS_FILE = "answers.txt"
APP_URL  = "https://www.facebook.com/Banamex/app/?sk=app_1585201315138559&__mref=message_bubble"
FB_URL   = "https://www.facebook.com/"
ANSWERS  = read_answers(ANS_FILE)
EMAIL    = ENV["FBUSER"]
PASS     = ENV["FBPASS"]

b = Watir::Browser.new
b.goto FB_URL
b.text_field(id: "email").set EMAIL
b.text_field(id: "pass").set PASS
b.button(id: "u_0_w").click

b.goto APP_URL

f = b.iframe :id, /app_runner/

# Click to start the quiz
f.div(class: "js-cerrar-fanblocker fanGate").click
f.link(class: "btnParticipate js-homelogin").click

# Answer each question
counter = 0
loop do
  # Sleep min 1 sec + random fraction
  begin
    fs = f.fieldset(class: "questionWrapper active")
    img = fs.img.src

    answer = ANSWERS[img]
    puts "ANSWER: #{answer}"
    fs.label(text: %r/#{answer}/i).click

    if counter == 9
      fs.link(class: "button btnParticipate js-btn-participate").click
      break
    end

    fs.link(class: "button btnParticipate js-btn-next").click

    counter += 1
  rescue Exception => e
    puts e.message
    retry
  end
  random_wait
end
