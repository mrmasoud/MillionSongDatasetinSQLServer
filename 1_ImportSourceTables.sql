﻿/*
Importing and using the Million Song Dataset (https://labrosa.ee.columbia.edu/millionsong/) in SQL Server 2017

Citation:
Thierry Bertin-Mahieux, Daniel P.W. Ellis, Brian Whitman, and Paul Lamere. 
The Million Song Dataset. In Proceedings of the 12th International Society
for Music Information Retrieval Conference (ISMIR 2011), 2011.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE. 

This sample code is not supported under any Microsoft standard support program or service.  
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.  
In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts 
be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, 
business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability 
to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages. 
*/

-- Reference: https://labrosa.ee.columbia.edu/millionsong/pages/getting-dataset
-- Data file: http://labrosa.ee.columbia.edu/millionsong/sites/default/files/AdditionalFiles/unique_tracks.txt
INSERT dbo.unique_tracks
SELECT        *
FROM OPENROWSET(BULK 'C:\MSD\SourceData\unique_tracks.txt', 
			FORMATFILE = 'C:\MSD\echonesttracks.fmt', 
			CODEPAGE = '65001') AS RawData
GO

-- Reference: https://labrosa.ee.columbia.edu/millionsong/tasteprofile
-- Data file (unzip manually please!): http://labrosa.ee.columbia.edu/millionsong/sites/default/files/challenge/train_triplets.txt.zip
INSERT dbo.[train_triplets]
SELECT        *
FROM OPENROWSET(BULK 'C:\MSD\SourceData\train_triplets.txt', 
			FORMATFILE = 'C:\MSD\train_triplets.fmt') AS RawData
GO

-- Fix up errors in the Echo Nest data
-- References: 
-- https://labrosa.ee.columbia.edu/millionsong/blog/12-1-2-matching-errors-taste-profile-and-msd
-- https://labrosa.ee.columbia.edu/millionsong/blog/12-2-12-fixing-matching-errors
-- Data file:
-- http://labrosa.ee.columbia.edu/millionsong/sites/default/files/tasteprofile/sid_mismatches.txt
UPDATE orig
SET orig.SongTitle = final.ActualSong,
orig.ArtistName = final.ActualArtist
FROM
	unique_tracks orig
	JOIN (
	SELECT *
	FROM
		OPENROWSET(BULK 'C:\MSD\SourceData\sid_mismatches.txt', 
				FORMATFILE = 'C:\MSD\sid_mismatches.fmt', CODEPAGE = '65001') AS MismatchedSongs
) AS final
	ON orig.SongId = final.SongId
WHERE ActualArtist IS NOT NULL
	AND ActualSong IS NOT NULL
GO

