from music21 import note, stream, environment


us = environment.UserSettings()
us['musicxmlPath'] = '//Applications/MuseScore 4.app'
us['musescoreDirectPNGPath'] = '/Applications/MuseScore 4.app'

s = stream.Stream()
s.append(note.Note('C4', quarterLength=1))
s.append(note.Note('E4', quarterLength=1))
s.append(note.Note('G4', quarterLength=1))

# Just write to MIDI - this doesn't need MuseScore at all
s.write('midi', fp='test.mid')
print("MIDI file created successfully!")




n1 = note.Note('C4')
#n1.show()
s.show()